local Class = require("game.class")
local Cache = require("game.cache")
local Config = require("game.config")
local Homecoming = require("game.homecoming")
local Level = require("game.level")
local LifeCounter = require("game.life_counter")
local MusicPlayer = require("game.music_player")
local Particle = require("game.particle")
local Player = require("game.player")
local RenderCache = require("game.render_cache")
local Util = require("game.util")
local Zone = require("game.zone")

local App = Class:extend()

local GAME_WIDTH = Config.width
local GAME_HEIGHT = Config.height
local GROUND_Y = Config.groundY
local LEVEL_END = Config.levelEnd
local HOME_X = Config.homeX

local state = "title"
local player
local platforms = {}
local hazards = {}
local foods = {}
local particles = {}
local clouds = {}
local cameraX = 0
local score = 0
local highScore = 0
local distance = 0
local elapsed = 0
local screenShake = 0
local flash = 0
local message = nil
local messageTimer = 0
local sounds = {}
local fonts = {}
local level
local lives = LifeCounter:new()
local homecoming
local music
local renderCache
local assetCache = Cache:new()

local zones = Zone.defaults()

local function currentZoneAt(x)
    return Zone.at(zones, x)
end

local function playSound(name)
    if sounds[name] then
        sounds[name]:stop()
        sounds[name]:play()
    end
end

local function makeTone(frequency, duration, volume, wave)
    local sampleRate = 22050
    local samples = math.floor(sampleRate * duration)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples - 1 do
        local time = i / sampleRate
        local envelope = math.min(1, time * 35) * math.max(0, 1 - time / duration)
        local value
        if wave == "square" then
            value = math.sin(time * frequency * math.pi * 2) >= 0 and 1 or -1
        else
            value = math.sin(time * frequency * math.pi * 2)
        end
        data:setSample(i, value * volume * envelope)
    end

    return love.audio.newSource(data, "static")
end

local function addParticle(x, y, color, count, speed)
    for _ = 1, count do
        local angle = love.math.random() * math.pi * 2
        local velocity = love.math.random(30, speed)
        table.insert(particles, Particle:new(
            x,
            y,
            math.cos(angle) * velocity,
            math.sin(angle) * velocity - 60,
            color,
            love.math.random() * 0.45 + 0.35,
            love.math.random(3, 8)
        ))
    end
end

local function resetGame()
    level = Level:new(function(...)
        return love.math.random(...)
    end):build()
    platforms = level.platforms
    hazards = level.hazards
    foods = level.foods
    zones = level.zones
    lives:reset()
    homecoming = nil
    player = Player:new(105, GROUND_Y - 62)
    cameraX = 0
    score = 0
    distance = 0
    elapsed = 0
    particles = {}
    screenShake = 0
    flash = 0
    message = "Spring, Miso, spring!"
    messageTimer = 2
end

local function startGame()
    resetGame()
    state = "playing"
    playSound("start")
end

local function killPlayer()
    if state ~= "playing" or player.invulnerable > 0 then
        return
    end

    local deathX = player.x + player.w / 2
    local deathY = player.y + player.h / 2
    screenShake = 16
    flash = 0.65
    addParticle(deathX, deathY, { 1.0, 0.35, 0.30 }, 24, 260)
    playSound("hurt")

    if lives:lose() then
        state = "gameover"
        highScore = math.max(highScore, score)
        return
    end

    local _, zoneIndex = currentZoneAt(player.x)
    local checkpointX = (zoneIndex - 1) * Config.zoneWidth + 200
    player = Player:new(checkpointX, GROUND_Y - 62)
    player.invulnerable = 1.5
    cameraX = math.max(0, checkpointX - 245)
    distance = math.floor(checkpointX / 10)
    message = lives:remaining() .. " liv kvar!"
    messageTimer = 2
end

local function requestJump()
    if state == "title" then
        startGame()
    elseif state == "gameover" or state == "won" then
        startGame()
    elseif state == "playing" then
        player:requestJump()
    end
end

function App:load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.math.setRandomSeed(os.time())

    fonts.small = love.graphics.newFont(20)
    fonts.medium = love.graphics.newFont(30)
    fonts.large = love.graphics.newFont(58)
    fonts.hero = love.graphics.newFont(82)
    renderCache = RenderCache:new(love.graphics)

    sounds.jump = makeTone(430, 0.12, 0.22, "square")
    sounds.food = makeTone(760, 0.10, 0.18, "sine")
    sounds.hurt = makeTone(120, 0.35, 0.28, "square")
    sounds.start = makeTone(520, 0.18, 0.18, "sine")
    sounds.win = makeTone(880, 0.45, 0.20, "sine")
    sounds.meow = assetCache:get("sound:cat-meow", function()
        return love.audio.newSource("assets/sounds/cat-meow.wav", "static")
    end)
    local musicSource = assetCache:get("music:retro-run", function()
        return love.audio.newSource("assets/music/retro-run.wav", "static")
    end)
    music = MusicPlayer:new(musicSource, 0.28)
    music:play()

    for i = 1, 12 do
        table.insert(clouds, {
            x = love.math.random(-300, LEVEL_END),
            y = love.math.random(70, 260),
            scale = love.math.random(7, 15) / 10,
            layer = love.math.random(1, 3),
        })
    end

    resetGame()
    state = "title"
end

function App:keypressed(key)
    if key == "space" or key == "up" or key == "w" then
        requestJump()
    elseif key == "return" and (state == "title" or state == "gameover" or state == "won") then
        startGame()
    elseif key == "p" or key == "escape" then
        if state == "playing" then
            state = "paused"
        elseif state == "paused" then
            state = "playing"
        end
    elseif key == "r" and (state == "gameover" or state == "won") then
        startGame()
    end
end

function App:keyreleased(key)
    if (key == "space" or key == "up" or key == "w") and state == "playing" then
        player:releaseJump()
    end
end

function App:mousepressed(_, _, button)
    if button == 1 then
        requestJump()
    end
end

local function updateParticles(dt)
    for i = #particles, 1, -1 do
        local particle = particles[i]
        if not particle:update(dt) then
            table.remove(particles, i)
        end
    end
end

local function addScore(points)
    score = score + points
    local extraLives = lives:awardForScore(score)
    if extraLives > 0 then
        message = extraLives == 1 and "Extraliv!" or extraLives .. " extraliv!"
        messageTimer = 2.2
        playSound("start")
    end
end

local function collectFood(food)
    addScore(food:collect())
    if food:shouldMeow(love.math.random) then
        playSound("meow")
    end
    local colors = {
        fish = { 0.38, 0.83, 1.0 },
        milk = { 0.96, 0.96, 1.0 },
        cake = { 1.0, 0.50, 0.66 },
    }
    addParticle(food.x, food.y, colors[food.kind], 10, 150)
    playSound("food")
end

local function updatePlaying(dt)
    player:updateTimers(dt)
    if player:updateJump(0) then
        addParticle(player.x + 24, player.y + player.h, { 0.85, 0.77, 0.62 }, 6, 90)
        playSound("jump")
    end

    local _, zoneIndex = currentZoneAt(player.x)
    local difficulty = level:getDifficulty(zoneIndex)
    local previousBottom = player:move(dt, difficulty:speedAt(player.x))

    if player.vy >= 0 then
        for _, platform in ipairs(platforms) do
            if platform:canLand(player, previousBottom) then
                player:land(platform.y)
                break
            end
        end
    end

    distance = math.floor(player.x / 10)
    cameraX = math.max(0, Util.lerp(cameraX, player.x - 245, math.min(1, dt * 4.8)))
    local hitbox = player:getHitbox()

    for _, hazard in ipairs(hazards) do
        if hazard:collidesWith(hitbox) then
            killPlayer()
            break
        end
    end

    for _, food in ipairs(foods) do
        if not food.collected and Util.rectsOverlap(hitbox, food:getHitbox()) then
            collectFood(food)
        end
    end

    if player.y > GAME_HEIGHT + 120 then
        killPlayer()
    elseif player.x >= LEVEL_END then
        state = "homecoming"
        homecoming = Homecoming:new(player.x, HOME_X)
        addScore(1000)
        highScore = math.max(highScore, score)
        addParticle(player.x, player.y, { 1.0, 0.85, 0.25 }, 40, 300)
        playSound("win")
        message = "Familjen väntar!"
        messageTimer = 2
    end

    local previousZone = currentZoneAt(math.max(0, player.x - player.speed * dt))
    if previousZone ~= zones[zoneIndex] and zoneIndex > 1 then
        message = zones[zoneIndex].name
        messageTimer = 2.2
    end
end

local function updateHomecoming(dt)
    local previousPhase = homecoming:phase()
    homecoming:update(dt)
    player.x = homecoming:catX()
    player.y = GROUND_Y - player.h
    player.vy = 0
    player.onGround = true
    player.runTimer = player.runTimer + dt * 4
    cameraX = math.max(0, Util.lerp(cameraX, player.x - 245, math.min(1, dt * 3.5)))

    if previousPhase ~= homecoming:phase() then
        message = "Äntligen hemma!"
        messageTimer = 2.5
        addParticle(player.x + player.w / 2, player.y, { 1.0, 0.45, 0.62 }, 30, 220)
    end

    if homecoming:isFinished() then
        state = "won"
    end
end

function App:update(dt)
    dt = math.min(dt, 1 / 30)
    elapsed = elapsed + dt
    if state == "playing" then
        updatePlaying(dt)
    elseif state == "homecoming" then
        updateHomecoming(dt)
    elseif state == "title" then
        player.runTimer = player.runTimer + dt * 2.5
    end

    updateParticles(dt)
    screenShake = math.max(0, screenShake - dt * 38)
    flash = math.max(0, flash - dt * 2.4)
    if messageTimer > 0 then
        messageTimer = messageTimer - dt
    end
end

local function setColor(color, alpha)
    love.graphics.setColor(color[1], color[2], color[3], alpha or 1)
end

local function drawSky(zone)
    local strips = 18
    for i = 0, strips - 1 do
        local amount = i / (strips - 1)
        setColor(Util.mixColor(zone.skyTop, zone.skyBottom, amount))
        love.graphics.rectangle("fill", 0, i * GAME_HEIGHT / strips, GAME_WIDTH, GAME_HEIGHT / strips + 1)
    end
end

local function drawCloud(x, y, scale, alpha)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.ellipse("fill", x, y, 50 * scale, 22 * scale)
    love.graphics.circle("fill", x - 28 * scale, y + 3 * scale, 20 * scale)
    love.graphics.circle("fill", x + 27 * scale, y + 4 * scale, 17 * scale)
    love.graphics.circle("fill", x + 3 * scale, y - 15 * scale, 27 * scale)
end

local function drawHomeScenery(parallax)
    for i = -1, 7 do
        local x = i * 250 - (cameraX * parallax) % 250
        local height = 125 + (i % 3) * 35
        love.graphics.setColor(0.91, 0.67 + (i % 2) * 0.08, 0.52)
        love.graphics.rectangle("fill", x, GROUND_Y - height, 180, height)
        love.graphics.setColor(0.56, 0.20, 0.17)
        love.graphics.polygon("fill", x - 16, GROUND_Y - height, x + 90, GROUND_Y - height - 75, x + 196, GROUND_Y - height)
        love.graphics.setColor(0.50, 0.79, 0.94)
        love.graphics.rectangle("fill", x + 28, GROUND_Y - height + 38, 35, 42)
        love.graphics.rectangle("fill", x + 112, GROUND_Y - height + 38, 35, 42)
    end
end

local function drawForestScenery(parallax)
    for i = -2, 12 do
        local x = i * 145 - (cameraX * parallax) % 145
        local height = 180 + (i % 4) * 28
        love.graphics.setColor(0.20, 0.30, 0.18, 0.75)
        love.graphics.rectangle("fill", x - 12, GROUND_Y - height, 25, height)
        love.graphics.setColor(0.18, 0.46 + (i % 2) * 0.08, 0.28, 0.85)
        love.graphics.circle("fill", x, GROUND_Y - height, 74)
        love.graphics.circle("fill", x - 44, GROUND_Y - height + 32, 51)
        love.graphics.circle("fill", x + 43, GROUND_Y - height + 28, 56)
    end
end

local function drawCityScenery(parallax)
    for i = -1, 9 do
        local x = i * 170 - (cameraX * parallax) % 170
        local height = 180 + (i * 47 % 190)
        love.graphics.setColor(0.31 + (i % 2) * 0.08, 0.34, 0.43, 0.88)
        love.graphics.rectangle("fill", x, GROUND_Y - height, 135, height)
        love.graphics.setColor(0.96, 0.76, 0.32, 0.70)
        for row = 0, math.floor(height / 55) - 1 do
            for column = 0, 2 do
                love.graphics.rectangle("fill", x + 16 + column * 39, GROUND_Y - height + 20 + row * 52, 18, 25)
            end
        end
    end
end

local function drawMountainScenery(parallax)
    love.graphics.setColor(0.13, 0.15, 0.28, 0.92)
    for i = -2, 5 do
        local x = i * 400 - (cameraX * parallax) % 400
        love.graphics.polygon("fill", x, GROUND_Y, x + 220, 185 + (i % 2) * 70, x + 460, GROUND_Y)
        love.graphics.setColor(0.64, 0.65, 0.79, 0.68)
        love.graphics.polygon("fill", x + 175, 245 + (i % 2) * 70, x + 220, 185 + (i % 2) * 70, x + 267, 251 + (i % 2) * 70)
        love.graphics.setColor(0.13, 0.15, 0.28, 0.92)
    end
end

local function drawBackground(zoneIndex)
    if zoneIndex == 4 then
        love.graphics.setColor(0.92, 0.91, 0.74, 0.88)
        love.graphics.circle("fill", 1040, 135, 67)
        love.graphics.setColor(0.72, 0.73, 0.70, 0.4)
        love.graphics.circle("fill", 1018, 118, 13)
        love.graphics.circle("fill", 1063, 151, 18)
    else
        love.graphics.setColor(1.0, 0.90, 0.42, 0.92)
        love.graphics.circle("fill", 1080, 115, 58)
    end

    for _, cloud in ipairs(clouds) do
        local speed = 0.05 + cloud.layer * 0.035
        local x = cloud.x - cameraX * speed
        while x < -180 do
            x = x + LEVEL_END + 700
        end
        while x > GAME_WIDTH + 180 do
            x = x - LEVEL_END - 700
        end
        drawCloud(x, cloud.y, cloud.scale, zoneIndex == 4 and 0.18 or 0.55)
    end

    if zoneIndex == 1 then
        drawHomeScenery(0.22)
    elseif zoneIndex == 2 then
        drawForestScenery(0.20)
    elseif zoneIndex == 3 then
        drawCityScenery(0.18)
    else
        drawMountainScenery(0.16)
    end
end

local function drawPlatforms(zone)
    for _, platform in ipairs(platforms) do
        local screenX = platform.x - cameraX
        if screenX + platform.w > -50 and screenX < GAME_WIDTH + 50 then
            setColor(zone.dirt)
            love.graphics.rectangle("fill", screenX, platform.y, platform.w, platform.h)
            setColor(zone.ground)
            love.graphics.rectangle("fill", screenX, platform.y, platform.w, math.min(18, platform.h), 5, 5)
            love.graphics.setColor(1, 1, 1, 0.13)
            love.graphics.rectangle("fill", screenX, platform.y, platform.w, 5, 3, 3)
        end
    end
end

local function renderFoodSprite(kind)
    if kind == "fish" then
        love.graphics.setColor(0.35, 0.76, 0.95)
        love.graphics.ellipse("fill", 0, 0, 19, 11)
        love.graphics.polygon("fill", -16, 0, -29, -12, -29, 12)
        love.graphics.setColor(0.06, 0.15, 0.24)
        love.graphics.circle("fill", 9, -3, 2.5)
    elseif kind == "milk" then
        love.graphics.setColor(0.96, 0.97, 1.0)
        love.graphics.polygon("fill", -13, -18, 9, -18, 15, -10, 15, 19, -15, 19, -15, -10)
        love.graphics.setColor(0.35, 0.67, 0.94)
        love.graphics.rectangle("fill", -15, -7, 30, 17)
        love.graphics.setColor(0.10, 0.28, 0.50)
        love.graphics.print("M", fonts.small, -8, -10, 0, 0.7, 0.7)
    else
        love.graphics.setColor(0.98, 0.72, 0.46)
        love.graphics.rectangle("fill", -19, -9, 38, 25, 5, 5)
        love.graphics.setColor(1.0, 0.45, 0.63)
        love.graphics.polygon("fill", -20, -8, 20, -8, 13, -20, -13, -20)
        love.graphics.setColor(1, 0.95, 0.75)
        love.graphics.circle("fill", 0, -19, 4)
    end
end

local function drawFood(food)
    local x = food.x - cameraX
    local y = food.y + math.sin(elapsed * 5 + food.bob) * 5
    local rotation = math.sin(elapsed * 3 + food.bob) * 0.08
    local sprite = renderCache:get("food:" .. food.kind, 64, 64, function()
        love.graphics.translate(32, 32)
        renderFoodSprite(food.kind)
    end)

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(rotation)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, -32, -32)
    love.graphics.pop()
end

local function renderHazardSprite(hazard)
    if hazard.kind == "crate" then
        love.graphics.setColor(0.56, 0.31, 0.14)
        love.graphics.rectangle("fill", 0, 0, hazard.w, hazard.h, 4, 4)
        love.graphics.setColor(0.79, 0.51, 0.23)
        love.graphics.setLineWidth(6)
        love.graphics.line(5, 6, hazard.w - 5, hazard.h - 6)
        love.graphics.line(hazard.w - 5, 6, 5, hazard.h - 6)
    elseif hazard.kind == "thorns" then
        love.graphics.setColor(0.66, 0.70, 0.76)
        for i = 0, 4 do
            local left = i * hazard.w / 5
            love.graphics.polygon("fill", left, hazard.h, left + hazard.w / 10, 0, left + hazard.w / 5, hazard.h)
        end
    elseif hazard.kind == "log" then
        love.graphics.setColor(0.39, 0.22, 0.12)
        love.graphics.rectangle("fill", 0, 7, hazard.w, hazard.h - 7, 15, 15)
        love.graphics.setColor(0.69, 0.43, 0.22)
        love.graphics.circle("fill", hazard.w - 4, hazard.h / 2 + 3, 16)
        love.graphics.setColor(0.30, 0.17, 0.10)
        love.graphics.circle("line", hazard.w - 4, hazard.h / 2 + 3, 8)
    end
end

local function drawHazard(hazard)
    local key = table.concat({ "hazard", hazard.kind, hazard.w, hazard.h }, ":")
    local sprite = renderCache:get(key, hazard.w + 18, hazard.h + 8, function()
        renderHazardSprite(hazard)
    end)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sprite, hazard.x - cameraX, hazard.y)
end

local function drawCat(x, y, scale, running)
    local cycle = player.runTimer
    local legSwing = running and math.sin(cycle * 2) * 8 or 0
    local bob = running and math.abs(math.sin(cycle * 2)) * 3 or math.sin(elapsed * 2) * 1.5
    local squashX = 1 + player.squash
    local squashY = 1 - player.squash

    love.graphics.push()
    love.graphics.translate(x + player.w / 2, y + player.h / 2 + bob)
    love.graphics.scale(scale * squashX, scale * squashY)
    love.graphics.translate(-player.w / 2, -player.h / 2)

    love.graphics.setColor(0.35, 0.22, 0.16)
    love.graphics.setLineWidth(8)
    love.graphics.arc("line", "open", 7, 32, 22, -2.7, -0.3)

    love.graphics.setColor(0.95, 0.57, 0.25)
    love.graphics.ellipse("fill", 31, 36, 29, 20)
    love.graphics.circle("fill", 50, 23, 21)
    love.graphics.polygon("fill", 34, 10, 39, -4, 49, 11)
    love.graphics.polygon("fill", 52, 9, 64, -2, 66, 16)

    love.graphics.setColor(1.0, 0.76, 0.45)
    love.graphics.ellipse("fill", 47, 31, 13, 12)
    love.graphics.setColor(0.99, 0.72, 0.73)
    love.graphics.polygon("fill", 52, 25, 58, 25, 55, 29)

    love.graphics.setColor(0.12, 0.12, 0.15)
    love.graphics.ellipse("fill", 46, 19, 3, 5)
    love.graphics.ellipse("fill", 59, 18, 3, 5)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(42, 29, 27, 27)
    love.graphics.line(42, 33, 27, 36)
    love.graphics.line(61, 29, 74, 25)
    love.graphics.line(61, 33, 76, 36)

    love.graphics.setColor(0.76, 0.37, 0.16)
    love.graphics.rectangle("fill", 13, 48 + legSwing * 0.28, 10, 14, 5, 5)
    love.graphics.rectangle("fill", 39, 48 - legSwing * 0.28, 10, 14, 5, 5)
    love.graphics.rectangle("fill", 25, 49 - legSwing * 0.22, 9, 13, 5, 5)

    love.graphics.setColor(0.28, 0.66, 0.86)
    love.graphics.rectangle("fill", 35, 35, 25, 5, 2, 2)
    love.graphics.circle("fill", 47, 40, 4)
    love.graphics.pop()
end

local function drawFamilyCat(x, y, scale, bodyColor, bellyColor, facingLeft)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(facingLeft and -scale or scale, scale)

    love.graphics.setColor(bodyColor)
    love.graphics.ellipse("fill", 0, -23, 23, 20)
    love.graphics.circle("fill", 14, -48, 17)
    love.graphics.polygon("fill", 2, -58, 7, -72, 15, -57)
    love.graphics.polygon("fill", 18, -58, 29, -69, 29, -51)

    love.graphics.setColor(bellyColor)
    love.graphics.ellipse("fill", 7, -20, 10, 13)
    love.graphics.setColor(0.12, 0.12, 0.15)
    love.graphics.circle("fill", 10, -51, 2)
    love.graphics.circle("fill", 21, -51, 2)
    love.graphics.setColor(0.98, 0.65, 0.70)
    love.graphics.polygon("fill", 14, -44, 20, -44, 17, -40)

    love.graphics.setColor(bodyColor)
    love.graphics.setLineWidth(6)
    love.graphics.arc("line", "open", -17, -27, 20, 1.9, 4.8)
    love.graphics.rectangle("fill", -14, -10, 9, 14, 4, 4)
    love.graphics.rectangle("fill", 10, -10, 9, 14, 4, 4)
    love.graphics.pop()
end

local function renderHome()
    local houseX = 35
    local houseY = 115
    love.graphics.setColor(0.94, 0.68, 0.45)
    love.graphics.rectangle("fill", houseX, houseY, 300, 245, 12, 12)
    love.graphics.setColor(0.55, 0.19, 0.20)
    love.graphics.polygon("fill", houseX - 35, houseY + 12, houseX + 150, houseY - 115, houseX + 335, houseY + 12)
    love.graphics.setColor(0.35, 0.20, 0.14)
    love.graphics.rectangle("fill", houseX + 28, houseY + 115, 78, 130, 24, 24)
    love.graphics.setColor(0.50, 0.82, 0.96)
    love.graphics.rectangle("fill", houseX + 180, houseY + 58, 70, 65, 8, 8)
    love.graphics.setColor(1, 1, 1, 0.65)
    love.graphics.rectangle("fill", houseX + 212, houseY + 58, 6, 65)
    love.graphics.rectangle("fill", houseX + 180, houseY + 87, 70, 6)
    love.graphics.setColor(0.98, 0.42, 0.52)
    love.graphics.circle("fill", houseX + 67, houseY + 167, 10)
    love.graphics.circle("fill", houseX + 82, houseY + 167, 10)
    love.graphics.polygon("fill", houseX + 58, houseY + 168, houseX + 91, houseY + 168, houseX + 75, houseY + 191)
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.30, 0.16, 0.12)
    love.graphics.printf("MISOS HEM", houseX + 122, houseY + 155, 150, "center")
end

local function drawHomeAndFamily()
    if state ~= "homecoming" and state ~= "won" then
        return
    end

    local houseX = HOME_X - cameraX
    local houseY = GROUND_Y - 245
    local homeSprite = renderCache:get("home", 370, 370, renderHome)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(homeSprite, houseX - 35, houseY - 115)

    local hugX = HOME_X - 90 - cameraX
    local hugging = homecoming and homecoming:phase() == "hugging" or state == "won"
    local spread = hugging and 23 or 48
    drawFamilyCat(hugX + spread, GROUND_Y - 3, 1.05, { 0.72, 0.68, 0.65 }, { 0.94, 0.92, 0.88 }, true)
    drawFamilyCat(hugX + spread * 2, GROUND_Y - 2, 0.90, { 0.96, 0.84, 0.60 }, { 1.0, 0.96, 0.83 }, true)
    drawFamilyCat(hugX + spread * 3, GROUND_Y - 2, 0.72, { 0.47, 0.43, 0.52 }, { 0.89, 0.86, 0.92 }, true)

    if hugging then
        love.graphics.setColor(1.0, 0.35, 0.52, 0.9)
        for i = 0, 2 do
            local heartX = hugX + 15 + i * 34
            local heartY = GROUND_Y - 115 - (i % 2) * 14
            love.graphics.circle("fill", heartX, heartY, 7)
            love.graphics.circle("fill", heartX + 10, heartY, 7)
            love.graphics.polygon("fill", heartX - 7, heartY + 2, heartX + 17, heartY + 2, heartX + 5, heartY + 20)
        end
    end
end

local function drawFinish()
    local x = LEVEL_END - cameraX
    if x > -100 and x < GAME_WIDTH + 100 then
        love.graphics.setColor(0.45, 0.28, 0.16)
        love.graphics.rectangle("fill", x, GROUND_Y - 145, 10, 145)
        love.graphics.setColor(0.96, 0.83, 0.33)
        love.graphics.polygon("fill", x + 10, GROUND_Y - 145, x + 106, GROUND_Y - 125, x + 10, GROUND_Y - 100)
        love.graphics.setColor(0.14, 0.16, 0.23)
        love.graphics.setFont(fonts.small)
        love.graphics.print("FRIHET!", x + 21, GROUND_Y - 137, -0.02, 0.72, 0.72)
    end
end

local function drawParticles()
    for _, particle in ipairs(particles) do
        local alpha = Util.clamp(particle.life / particle.maxLife, 0, 1)
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], alpha)
        love.graphics.circle("fill", particle.x - cameraX, particle.y, particle.size * alpha)
    end
end

local function drawHUD(zone)
    love.graphics.setColor(0.05, 0.07, 0.12, 0.74)
    love.graphics.rectangle("fill", 25, 23, 455, 83, 18, 18)
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("POÄNG", 48, 37)
    love.graphics.print("STRÄCKA", 190, 37)
    love.graphics.print("LIV", 350, 37)
    love.graphics.setFont(fonts.medium)
    setColor(zone.accent)
    love.graphics.print(string.format("%05d", score), 47, 61)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(distance .. " m", 190, 61)
    love.graphics.setColor(1.0, 0.45, 0.52)
    love.graphics.print("♥ x " .. lives:remaining(), 347, 61)

    local progress = Util.clamp(player.x / LEVEL_END, 0, 1)
    love.graphics.setColor(0.05, 0.07, 0.12, 0.58)
    love.graphics.rectangle("fill", GAME_WIDTH - 355, 35, 315, 26, 13, 13)
    setColor(zone.accent)
    love.graphics.rectangle("fill", GAME_WIDTH - 350, 40, 305 * progress, 16, 8, 8)
    drawCat(GAME_WIDTH - 360 + 305 * progress, 27, 0.42, false)

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1, 0.88)
    love.graphics.printf(zone.name, GAME_WIDTH - 355, 72, 315, "right")
end

local function drawOverlay(title, subtitle, prompt, color)
    love.graphics.setColor(0.02, 0.03, 0.08, 0.68)
    love.graphics.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
    love.graphics.setFont(fonts.hero)
    setColor(color)
    love.graphics.printf(title, 0, 185, GAME_WIDTH, "center")
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(subtitle, 220, 300, GAME_WIDTH - 440, "center")
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1, 0.76 + math.sin(elapsed * 4) * 0.18)
    love.graphics.printf(prompt, 0, 430, GAME_WIDTH, "center")
end

local function drawGame()
    local zone = currentZoneAt(player.x)
    drawSky(zone)
    drawBackground(select(2, currentZoneAt(player.x)))

    love.graphics.push()
    if screenShake > 0 then
        local shakeX = (love.math.random() * 2 - 1) * screenShake
        local shakeY = (love.math.random() * 2 - 1) * screenShake
        love.graphics.translate(shakeX, shakeY)
    end

    drawPlatforms(zone)
    for _, food in ipairs(foods) do
        if not food.collected and food.x - cameraX > -60 and food.x - cameraX < GAME_WIDTH + 60 then
            drawFood(food)
        end
    end
    for _, hazard in ipairs(hazards) do
        if hazard.x - cameraX > -100 and hazard.x - cameraX < GAME_WIDTH + 100 then
            drawHazard(hazard)
        end
    end
    drawFinish()
    drawHomeAndFamily()
    local running = state == "playing" and player.onGround
        or state == "homecoming" and homecoming:phase() == "approaching"
    drawCat(player.x - cameraX, player.y, 1, running)
    drawParticles()
    love.graphics.pop()

    if state ~= "title" then
        drawHUD(zone)
    end

    if messageTimer > 0 and (state == "playing" or state == "homecoming") then
        local alpha = Util.clamp(messageTimer, 0, 1)
        love.graphics.setFont(fonts.large)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.printf(message, 0, 145, GAME_WIDTH, "center")
    end

    if state == "title" then
        love.graphics.setColor(0.03, 0.05, 0.10, 0.34)
        love.graphics.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
        love.graphics.setFont(fonts.hero)
        love.graphics.setColor(1.0, 0.71, 0.29)
        love.graphics.printf("KATTEN PÅ RYMMEN", 0, 110, GAME_WIDTH, "center")
        love.graphics.setFont(fonts.medium)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Hjälp Miso fly hemifrån och hitta friheten!", 0, 225, GAME_WIDTH, "center")
        drawCat(GAME_WIDTH / 2 - 55, 305, 1.65, false)
        love.graphics.setFont(fonts.small)
        love.graphics.setColor(1, 1, 1, 0.72)
        love.graphics.printf("HOPPA: MELLANSLAG / W / ↑ / MUSKLICK", 0, 485, GAME_WIDTH, "center")
        love.graphics.setColor(1, 1, 1, 0.82 + math.sin(elapsed * 4) * 0.18)
        love.graphics.printf("TRYCK ENTER ELLER MELLANSLAG FÖR ATT STARTA", 0, 545, GAME_WIDTH, "center")
    elseif state == "paused" then
        drawOverlay("PAUS", "Miso tar en liten kattlur.", "Tryck P eller Esc för att fortsätta", { 0.45, 0.84, 1.0 })
    elseif state == "gameover" then
        drawOverlay(
            "AJDÅ!",
            "Miso blev stoppad efter " .. distance .. " meter.\nPoäng: " .. score .. "   Bästa: " .. highScore,
            "Tryck R, Enter eller Mellanslag för att försöka igen",
            { 1.0, 0.38, 0.34 }
        )
    elseif state == "won" then
        drawOverlay(
            "HEMMA!",
            "Miso är trygg hemma hos sin kattfamilj!\nSlutpoäng: " .. score,
            "Tryck R, Enter eller Mellanslag för att springa igen",
            { 1.0, 0.84, 0.27 }
        )
    end

    if flash > 0 then
        love.graphics.setColor(1, 1, 1, flash)
        love.graphics.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
    end
end

function App:draw()
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scale = math.min(windowWidth / GAME_WIDTH, windowHeight / GAME_HEIGHT)
    local offsetX = (windowWidth - GAME_WIDTH * scale) / 2
    local offsetY = (windowHeight - GAME_HEIGHT * scale) / 2

    love.graphics.clear(0.025, 0.03, 0.06)
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)
    drawGame()
    love.graphics.pop()
end

return App
