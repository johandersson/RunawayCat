local ChaserDog = require("game.chaser_dog")
local Config = require("game.config")
local Difficulty = require("game.difficulty")
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

                for _ = 1, 1200 do
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

    it("increases pressure progressively without removing the warning", function()
        local previous
        for levelIndex = 1, 3 do
            local worldCount = levelIndex == 1 and 4 or 5
            for zoneIndex = 1, worldCount do
                local difficulty = Difficulty.forZone(zoneIndex, levelIndex)
                assert.is_true(difficulty.chaserWarning >= 30)
                if previous then
                    assert.is_true(difficulty.chaserCatchup >= previous.chaserCatchup)
                    assert.is_true(difficulty.chaserDistance <= previous.chaserDistance)
                end
                previous = difficulty
            end
        end
    end)
end)
