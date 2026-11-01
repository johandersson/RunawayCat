local LifeCounter = require("game.life_counter")

describe("LifeCounter", function()
    it("starts each run with three lives", function()
        local lives = LifeCounter:new()

        assert.equals(3, lives:remaining())
        assert.is_false(lives:isGameOver())
    end)

    it("allows two deaths before game over", function()
        local lives = LifeCounter:new()

        assert.is_false(lives:lose())
        assert.equals(2, lives:remaining())
        assert.is_false(lives:lose())
        assert.equals(1, lives:remaining())
    end)

    it("ends the run on the third death", function()
        local lives = LifeCounter:new()

        lives:lose()
        lives:lose()

        assert.is_true(lives:lose())
        assert.equals(0, lives:remaining())
        assert.is_true(lives:isGameOver())
    end)

    it("can reset for a new run", function()
        local lives = LifeCounter:new()
        lives:lose()

        lives:reset()

        assert.equals(3, lives:remaining())
    end)

    it("awards an extra life at 2000 points", function()
        local lives = LifeCounter:new()

        assert.equals(0, lives:awardForScore(1999))
        assert.equals(1, lives:awardForScore(2000))
        assert.equals(4, lives:remaining())
    end)

    it("awards each score threshold only once", function()
        local lives = LifeCounter:new()

        assert.equals(1, lives:awardForScore(2000))
        assert.equals(0, lives:awardForScore(2000))
        assert.equals(0, lives:awardForScore(3999))
        assert.equals(4, lives:remaining())
    end)

    it("awards multiple lives when several thresholds are crossed", function()
        local lives = LifeCounter:new()

        assert.equals(3, lives:awardForScore(6000))
        assert.equals(6, lives:remaining())
        assert.equals(8000, lives:nextAwardScore())
    end)

    it("resets the next extra-life threshold for a new run", function()
        local lives = LifeCounter:new()
        lives:awardForScore(4000)

        lives:reset()

        assert.equals(2000, lives:nextAwardScore())
    end)
end)
