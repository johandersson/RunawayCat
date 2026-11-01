local Food = require("game.food")
local Hazard = require("game.hazard")
local Platform = require("game.platform")

describe("Game entities", function()
    it("awards each food type exactly once", function()
        local fish = Food:new(10, 20, "fish")
        local milk = Food:new(10, 20, "milk")
        local cake = Food:new(10, 20, "cake")

        assert.equals(100, fish:collect())
        assert.equals(175, milk:collect())
        assert.equals(250, cake:collect())
        assert.equals(0, cake:collect())
    end)

    it("sometimes meows when a fish is eaten", function()
        local fish = Food:new(10, 20, "fish")
        local milk = Food:new(10, 20, "milk")

        assert.is_true(fish:shouldMeow(function()
            return 0.29
        end))
        assert.is_false(fish:shouldMeow(function()
            return 0.30
        end))
        assert.is_false(milk:shouldMeow(function()
            return 0
        end))
    end)

    it("uses padded collision for hazards", function()
        local hazard = Hazard:new(100, 100, 40, 40, "crate")

        assert.is_true(hazard:collidesWith({ x = 105, y = 105, w = 20, h = 20 }))
        assert.is_false(hazard:collidesWith({ x = 20, y = 20, w = 20, h = 20 }))
    end)

    it("detects when a falling player lands on a platform", function()
        local platform = Platform:new(100, 300, 200, 30)
        local player = { x = 130, y = 250, w = 60, h = 58 }

        assert.is_true(platform:canLand(player, 290))
        assert.is_false(platform:canLand(player, 310))
    end)
end)
