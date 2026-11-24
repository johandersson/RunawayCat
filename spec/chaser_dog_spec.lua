local ChaserDog = require("game.chaser_dog")
local Config = require("game.config")
local Difficulty = require("game.difficulty")
local Level = require("game.level")
local Player = require("game.player")

describe("Dog pursuing from behind", function()
    it("waits through the opening stretch and then starts behind Miso", function()
        local dog = ChaserDog:new()
        local player = Player:new(600, Config.groundY - 58)
        local difficulty = Difficulty.forZone(1, 1)

        assert.is_false(dog:update(1, player, difficulty))
        assert.is_false(dog.active)
        player.x = 700
        dog:update(0, player, difficulty)

        assert.is_true(dog.active)
        assert.equals(difficulty.chaserDistance, player.x - (dog.x + dog.w))
        assert.is_true(dog.facingRight)
    end)

    it("warns once as it closes in and catches a grounded cat", function()
        local dog = ChaserDog:new()
        local player = Player:new(700, Config.groundY - 58)
        local difficulty = Difficulty.forZone(3, 2)
        player.speed = difficulty.startSpeed
        local barked = 0

        for _ = 1, 900 do
            player.x = player.x + player.speed / 60
            if dog:update(1 / 60, player, difficulty) then
                barked = barked + 1
            end
            if dog:collidesWith(player:getHitbox()) then
                break
            end
        end

        assert.equals(1, barked)
        assert.is_true(dog:collidesWith(player:getHitbox()))
    end)

    it("can be escaped with a timed jump at the easiest and hardest settings", function()
        for _, dt in ipairs({ 1 / 60, 1 / 30 }) do
            for _, setting in ipairs({ { 1, 1 }, { 3, 5 } }) do
                local levelIndex, zoneIndex = setting[1], setting[2]
                local difficulty = Difficulty.forZone(zoneIndex, levelIndex)
                local dog = ChaserDog:new()
                local player = Player:new(700, Config.groundY - 58)
                local escaped = false

                for _ = 1, 2400 do
                    local gap = player.x - (dog.x + dog.w)
                    if dog.active and player.onGround and gap <= difficulty.chaserWarning then
                        player:requestJump()
                    end
                    player:updateTimers(dt)
                    player:updateJump(0)
                    player:move(dt, difficulty.startSpeed)
                    if player.y + player.h >= Config.groundY and player.vy >= 0 then
                        player:land(Config.groundY)
                    end
                    dog:update(dt, player, difficulty)
                    assert.is_false(dog:collidesWith(player:getHitbox()),
                        "Chaser collision at level=" .. levelIndex .. " zone=" .. zoneIndex .. " dt=" .. dt)
                    if dog.escapes > 0 then
                        escaped = true
                        break
                    end
                end

                assert.is_true(escaped)
            end
        end
    end)

    it("jumps over generated gaps instead of floating or falling through them", function()
        for _, dt in ipairs({ 1 / 60, 1 / 30 }) do
            local level = Level:new(nil, 1):build()
            local gap = assert(level.gaps[1])
            local zoneIndex = math.floor(gap.x / Config.zoneWidth) + 1
            local difficulty = level:getDifficulty(zoneIndex)
            local dog = ChaserDog:new()
            local player = Player:new(gap.x + 300, Config.groundY - 58)
            dog.active = true
            dog.x = gap.x - dog.w - 70
            player.speed = difficulty.startSpeed
            local becameAirborne = false
            local landedBeyondGap = false

            for _ = 1, 180 do
                player.x = player.x + player.speed * dt
                dog:update(dt, player, difficulty, { gap })
                becameAirborne = becameAirborne or not dog.onGround
                assert.is_true(dog.y + dog.h <= Config.groundY + 0.001)
                if dog.onGround and dog.x + dog.w / 2 > gap.x + gap.width then
                    landedBeyondGap = true
                    break
                end
            end

            assert.is_true(becameAirborne)
            assert.is_true(landedBeyondGap)
        end
    end)

    it("randomizes takeoff timing while still jumping normal hazards", function()
        local function takeoffX(offset)
            local difficulty = Difficulty.forZone(3, 1)
            local dog = ChaserDog:new()
            local player = Player:new(1500, Config.groundY - 58)
            local hazard = { x = 1050, y = Config.groundY - 34, w = 36, h = 34, kind = "crate" }
            dog.active = true
            dog.x = hazard.x - dog.w - 100
            player.speed = difficulty.startSpeed

            for _ = 1, 120 do
                player.x = player.x + player.speed / 60
                dog:update(1 / 60, player, difficulty, {}, { hazard }, function()
                    return offset
                end)
                if not dog.onGround then
                    assert.is_true(dog.x + dog.w < hazard.x)
                    return dog.x
                end
            end
            error("Dog did not jump the hazard")
        end

        local earlyTakeoff = takeoffX(10)
        local lateTakeoff = takeoffX(-10)

        assert.is_true(earlyTakeoff < lateTakeoff)
    end)

    it("is defeated only when Miso stomps downward from above", function()
        local dog = ChaserDog:new()
        dog.active = true
        dog.x = 1000
        local player = Player:new(1020, dog.y - 63)
        player.onGround = false
        player.vy = 120
        local previousBottom = player.y + player.h
        player.y = player.y + 12

        assert.is_true(dog:isStompedBy(player, previousBottom))
        dog:defeat()
        assert.is_true(dog.defeated)
        assert.is_false(dog.running)

        dog:reset(1200, 500)
        player.y = Config.groundY - player.h
        player.onGround = true
        player.vy = 0
        assert.is_false(dog:isStompedBy(player, player.y + player.h))
        assert.is_false(dog.defeated)
    end)

    it("increases pressure progressively without removing the warning", function()
        local previous
        for levelIndex = 1, 3 do
            local worldCount = levelIndex == 1 and 4 or 5
            for zoneIndex = 1, worldCount do
                local difficulty = Difficulty.forZone(zoneIndex, levelIndex)
                assert.is_true(difficulty.chaserWarning >= 25)
                if previous then
                    assert.is_true(difficulty.chaserCatchup >= previous.chaserCatchup)
                    assert.is_true(difficulty.chaserDistance <= previous.chaserDistance)
                end
                previous = difficulty
            end
        end
        assert.equals(22, Difficulty.forZone(1, 1).chaserCatchup)
        assert.equals(630, Difficulty.forZone(1, 1).chaserDistance)
        assert.is_true(Difficulty.forZone(5, 3).chaserCatchup <= 59)
        assert.is_true(Difficulty.forZone(5, 3).chaserDistance >= 390)
    end)
end)
