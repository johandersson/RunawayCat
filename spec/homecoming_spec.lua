local Homecoming = require("game.homecoming")

describe("Homecoming", function()
    it("starts with Miso approaching the family home", function()
        local homecoming = Homecoming:new(11900, 12450)

        assert.equals("approaching", homecoming:phase())
        assert.equals(11900, homecoming:catX())
        assert.is_false(homecoming:isFinished())
    end)

    it("moves Miso toward the family without passing the hug point", function()
        local homecoming = Homecoming:new(11900, 12450)

        homecoming:update(1)

        assert.is_true(homecoming:catX() > 11900)
        assert.is_true(homecoming:catX() <= homecoming:hugX())
    end)

    it("holds a family hug before finishing the celebration", function()
        local homecoming = Homecoming:new(11900, 12050)

        homecoming:update(1)
        assert.equals("hugging", homecoming:phase())
        assert.is_false(homecoming:isFinished())

        homecoming:update(3)
        assert.is_true(homecoming:isFinished())
    end)
end)
