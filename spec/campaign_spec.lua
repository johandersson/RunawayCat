local App = require("game.app")
local LoveMock = require("spec.support.love_mock")

local function upvalue(fn, name, visited)
    visited = visited or {}
    if visited[fn] then
        return nil
    end
    visited[fn] = true
    for i = 1, 100 do
        local key, value = debug.getupvalue(fn, i)
        if not key then
            break
        end
        if key == name then
            return value
        end
        if type(value) == "function" then
            local found = upvalue(value, name, visited)
            if found ~= nil then
                return found
            end
        end
    end
end

local function setUpvalue(fn, name, newValue, visited)
    visited = visited or {}
    if visited[fn] then
        return false
    end
    visited[fn] = true
    for i = 1, 100 do
        local key, value = debug.getupvalue(fn, i)
        if not key then
            break
        end
        if key == name then
            debug.setupvalue(fn, i, newValue)
            return true
        end
        if type(value) == "function" and setUpvalue(value, name, newValue, visited) then
            return true
        end
    end
    return false
end

local function completeLevel(app)
    local player = assert(upvalue(App.update, "player"))
    local level = assert(upvalue(App.update, "level"))
    player.x = level.finishX
    app:update(1 / 60)
    assert.equals("homecoming", app:getStatus().state)
    for _ = 1, 500 do
        app:update(1 / 60)
        if app:getStatus().state ~= "homecoming" then
            return
        end
    end
    error("Homecoming did not finish")
end

describe("Two-level campaign", function()
    local app

    before_each(function()
        LoveMock.install()
        app = App:new()
        app:load()
        app:keypressed("return")
    end)

    it("enters the indoor adventure after the outdoor homecoming", function()
        local lives = assert(upvalue(App.update, "lives"))
        lives:lose()
        completeLevel(app)

        local status = app:getStatus()
        assert.equals(2, status.levelIndex)
        assert.equals("playing", status.state)
        assert.equals(2, status.lives)
        assert.is_true(status.score >= 1000)
        assert.equals(5, status.worldCount)
    end)

    it("finishes only after completing the indoor adventure", function()
        completeLevel(app)
        completeLevel(app)

        assert.equals("won", app:getStatus().state)
        assert.equals(2, app:getStatus().levelIndex)
        app:keypressed("r")
        assert.equals(1, app:getStatus().levelIndex)
        assert.equals(3, app:getStatus().lives)
        assert.equals(0, app:getStatus().score)
    end)

    it("offers and persists the castle unlock after both levels above 20,000 points", function()
        completeLevel(app)
        assert.is_true(setUpvalue(App.update, "score", 20001))
        completeLevel(app)

        assert.equals("castle_unlock", app:getStatus().state)
        assert.is_false(app:getStatus().castleUnlocked)
        assert.has_no.errors(function() app:draw() end)

        app:keypressed("return")
        assert.equals("playing", app:getStatus().state)
        assert.equals(3, app:getStatus().levelIndex)
        assert.equals(5, app:getStatus().worldCount)
        assert.is_true(app:getStatus().castleUnlocked)
        local music = assert(upvalue(App.update, "music"))
        assert.equals("assets/music/castle-mystery.ogg", music.source.path)
        assert.equals(1, music.source.pitch)
        assert.equals(0.93, music.source.volume)

        local player = assert(upvalue(App.update, "player"))
        for area = 1, 5 do
            player.x = (area - 1) * 2800 + 200
            assert.has_no.errors(function() app:draw() end)
        end

        completeLevel(app)
        assert.equals("won", app:getStatus().state)

        app:keypressed("r")
        completeLevel(app)
        assert.is_true(setUpvalue(App.update, "score", 0))
        completeLevel(app)
        assert.equals("playing", app:getStatus().state)
        assert.equals(3, app:getStatus().levelIndex)
    end)

    it("keeps the castle locked when the reward is declined", function()
        completeLevel(app)
        assert.is_true(setUpvalue(App.update, "score", 20001))
        completeLevel(app)

        app:keypressed("right")
        app:keypressed("return")

        assert.equals("won", app:getStatus().state)
        assert.equals(2, app:getStatus().levelIndex)
        assert.is_false(app:getStatus().castleUnlocked)
    end)

    it("renders every indoor world and its hazards through the existing cache", function()
        completeLevel(app)
        local player = assert(upvalue(App.update, "player"))
        for world = 1, 5 do
            player.x = (world - 1) * 2800 + 200
            for _ = 1, 120 do
                app:update(1 / 60)
            end
            assert.has_no.errors(function()
                app:draw()
            end)
        end
    end)

    it("changes soundtrack on entering the house and restores it on restart", function()
        local music = assert(upvalue(App.update, "music"))
        local outdoor = music.source
        assert.equals("assets/music/retro-run.wav", outdoor.path)
        assert.equals(0.18, outdoor.volume)

        completeLevel(app)
        local indoor = music.source
        assert.equals("assets/music/retro-home.mp3", indoor.path)
        assert.is_false(outdoor.playing)
        assert.is_true(indoor.playing)
        assert.equals(0.90, indoor.pitch)
        assert.equals(1.00, indoor.volume)

        completeLevel(app)
        app:keypressed("r")
        assert.is_true(outdoor == music.source)
        assert.is_false(indoor.playing)
        assert.is_true(outdoor.playing)
        assert.equals(1, outdoor.pitch)
        assert.equals(0.18, outdoor.volume)
    end)

    it("keeps the final result visible until restart or exit is chosen", function()
        completeLevel(app)
        completeLevel(app)
        local status = app:getStatus()
        assert.is_true(status.highScore >= status.score)
        for _ = 1, 300 do app:update(1 / 60) end
        app:keypressed("space")
        app:keypressed("w")
        app:mousepressed(10, 10, 1)
        assert.equals("won", app:getStatus().state)
        app:keypressed("right")
        app:keypressed("return")
        assert.is_true(love.event.quitRequested)
    end)

    it("loses a life when caught by the final dog and shows results on the last life", function()
        completeLevel(app)
        local lives = upvalue(App.update, "lives")
        lives:lose()
        lives:lose()
        local level = upvalue(App.update, "level")
        local player = upvalue(App.update, "player")
        player.x = level.dog.x + 10
        player.y = 590 - player.h
        player.invulnerable = 0
        app:update(1 / 60)
        assert.equals("gameover", app:getStatus().state)
        assert.equals(0, app:getStatus().lives)
        app:keypressed("space")
        assert.equals("gameover", app:getStatus().state)
        app:keypressed("r")
        assert.equals("playing", app:getStatus().state)
    end)

    it("uses letterboxed screen coordinates for explicit result buttons", function()
        completeLevel(app)
        completeLevel(app)
        love.graphics.getDimensions = function() return 1000, 800 end
        local scale = 1000 / 1280
        local top = (800 - 720 * scale) / 2
        app:mousepressed(450 * scale, 470 * scale + top, 1)
        assert.equals("playing", app:getStatus().state)
        assert.equals(1, app:getStatus().levelIndex)
        assert.equals(3, app:getStatus().lives)
        assert.equals(0, app:getStatus().score)
    end)

    it("does not confirm a result choice through a repeated held Enter key", function()
        completeLevel(app)
        completeLevel(app)
        app:keypressed("return", "return", true)
        assert.equals("won", app:getStatus().state)
    end)

    it("does not meow when collecting food even on the former lucky roll", function()
        local source = upvalue(App.update, "meow").source
        local before = source.plays
        local player = upvalue(App.update, "player")
        local level = upvalue(App.update, "level")
        local fish
        for _, food in ipairs(level.foods) do
            if food.kind == "fish" then fish = food; break end
        end
        assert.is_not_nil(fish)
        fish.x, fish.y = player.x + player.w / 2, player.y + player.h / 2
        love.math.random = function() return 0 end
        app:update(1 / 60)
        assert.is_true(fish.collected)
        assert.equals(before, source.plays)
    end)

    it("meows exactly once for each lost life, including the final life", function()
        local source = upvalue(App.update, "meow").source
        local before = source.plays
        for lost = 1, 3 do
            local player = upvalue(App.update, "player")
            player.invulnerable = 0
            player.y = 1000
            app:update(1 / 60)
            assert.equals(3 - lost, app:getStatus().lives)
            assert.equals(before + lost, source.plays)
        end
        assert.equals("gameover", app:getStatus().state)
        app:update(1 / 60)
        assert.equals(before + 3, source.plays)
    end)

    it("does not meow on a collision while invulnerable", function()
        completeLevel(app)
        local source = upvalue(App.update, "meow").source
        local before = source.plays
        local level = upvalue(App.update, "level")
        local player = upvalue(App.update, "player")
        player.x = level.dog.x + 10
        player.y = 590 - player.h
        player.invulnerable = 1
        app:update(1 / 60)
        assert.equals(3, app:getStatus().lives)
        assert.equals(before, source.plays)
    end)

    it("plays a real bark as the dog runs toward Miso in either level", function()
        for index = 1, 2 do
            if index == 2 then completeLevel(app) end
            local level = upvalue(App.update, "level")
            local player = upvalue(App.update, "player")
            local bark = upvalue(App.update, "sounds").bark
            local plays = bark.plays
            assert.equals("assets/sounds/dog-bark.wav", bark.path)
            player.x = level.dog.x - 350
            local beforeX = level.dog.x
            app:update(1 / 60)
            assert.equals(plays + 1, bark.plays)
            assert.is_true(level.dog.x < beforeX)
            assert.has_no.errors(function() app:draw() end)
        end
    end)

    it("loses a life when the pursuing dog catches Miso from behind", function()
        local level = assert(upvalue(App.update, "level"))
        local player = assert(upvalue(App.update, "player"))
        player.x = 800
        player.y = 590 - player.h
        player.invulnerable = 0
        level.chaser.active = true
        level.chaser.x = player.x - 30

        app:update(1 / 60)

        assert.equals(2, app:getStatus().lives)
        assert.is_true(level.chaser.x < player.x)
    end)

    it("defeats the pursuing dog and awards points for a downward stomp", function()
        local level = assert(upvalue(App.update, "level"))
        local player = assert(upvalue(App.update, "player"))
        player.x = 800
        level.chaser.active = true
        level.chaser.x = player.x + 5
        player.y = level.chaser.y - player.h - 4
        player.vy = 300
        player.onGround = false
        local scoreBefore = app:getStatus().score

        app:update(1 / 60)

        assert.is_true(level.chaser.defeated)
        assert.equals(3, app:getStatus().lives)
        assert.equals(scoreBefore + 500, app:getStatus().score)
        assert.is_true(player.vy < 0)
    end)
end)
