local Config = require("game.config")
local Dog = require("game.dog")
local Level = require("game.level")
local Player = require("game.player")

describe("Running barking dog", function()
    it("guards the finish in both adventures", function()
        for index = 1, 2 do
            local level = Level:new(nil, index):build()
            assert.equals("dog", level.dog.kind)
            assert.is_true(level.dog.x > level.finishX - 350)
            assert.is_true(level.dog.x + level.dog.w < level.finishX)
        end
    end)

    it("is bigger than Miso but remains jumpable", function()
        local dog = Dog:new(1000)
        local player = Player:new(0, Config.groundY - 58)
        assert.is_true(dog.w > player.w and dog.h > player.h)
        assert.is_true(dog.h < Config.jumpVelocity ^ 2 / (2 * Config.gravity))
    end)

    it("runs toward Miso rather than stopping after a short lunge", function()
        local dog = Dog:new(1000)
        local player = Player:new(760, Config.groundY - 58)
        assert.is_true(dog:update(1 / 60, player))
        assert.is_true(dog.x < 1000)
        assert.is_false(dog:update(1 / 60, player))
        dog:update(0.5, player)
        assert.is_true(dog.x < 950)
        assert.is_true(dog.running)
    end)

    it("waits for Miso and limits repeated barking while running", function()
        local dog = Dog:new(1000)
        local player = Player:new(0, Config.groundY - 58)
        assert.is_false(dog:update(1, player))
        assert.equals(1000, dog.x)
        player.x = 760
        assert.is_true(dog:update(1 / 60, player))
        for _ = 1, 28 do
            player.x = dog.x - 240
            assert.is_false(dog:update(0.1, player))
        end
        player.x = dog.x - 240
        assert.is_true(dog:update(0.3, player))
    end)

    it("catches a grounded cat but allows a jump over its head", function()
        local dog = Dog:new(1000)
        local player = Player:new(1010, Config.groundY - 58)
        assert.is_true(dog:collidesWith(player:getHitbox()))
        player.y = Config.groundY - 58 - 100
        assert.is_false(dog:collidesWith(player:getHitbox()))
    end)

    it("stops attacking after Miso clears it and resets on retry", function()
        local dog = Dog:new(1000)
        local player = Player:new(1200, Config.groundY - 58)
        dog:update(1 / 60, player)
        assert.is_true(dog.passed)
        dog:reset()
        assert.is_false(dog.passed)
        assert.equals(1000, dog.x)
        assert.is_false(dog.running)
    end)

    it("can be jumped over at both finish speeds at 30 and 60 Hz", function()
        for _, dt in ipairs({ 1 / 30, 1 / 60 }) do
            for _, speed in ipairs({ 335, 440 }) do
                local dog = Dog:new(1000)
                local player = Player:new(450, Config.groundY - 58)
                for _ = 1, 180 do
                    local ahead = dog.x - player.x - player.w
                    if player.onGround and ahead >= 0 and ahead < 100 then
                        player:requestJump()
                    end
                    player:updateTimers(dt)
                    player:updateJump(0)
                    player:move(dt, speed)
                    if player.y + player.h >= Config.groundY and player.vy >= 0 then
                        player:land(Config.groundY)
                    end
                    dog:update(dt, player)
                    assert.is_false(dog:collidesWith(player:getHitbox()),
                        "Dog collision at speed=" .. speed .. " dt=" .. dt)
                    if dog.passed then break end
                end
                assert.is_true(dog.passed)
            end
        end
    end)
end)
