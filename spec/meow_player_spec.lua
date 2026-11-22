local Food = require("game.food")
local MeowPlayer = require("game.meow_player")

describe("Rare quiet meows", function()
    local source
    local meow
    local fish
    before_each(function()
        source = {
            plays = 0,
            setVolume = function(self, volume) self.volume = volume end,
            stop = function() end,
            play = function(self) self.plays = self.plays + 1 end,
        }
        meow = MeowPlayer:new(source)
        fish = Food:new(0, 0, "fish")
    end)

    it("keeps the meow quieter than music", function()
        assert.is_true(source.volume <= 0.10)
        assert.is_true(source.volume < 0.28)
    end)

    it("never repeats a meow within twelve seconds", function()
        local rareRoll = function() return 0 end
        assert.is_true(meow:tryPlay(fish, 0, rareRoll))
        assert.is_false(meow:tryPlay(fish, 11.99, rareRoll))
        assert.is_true(meow:tryPlay(fish, 12, rareRoll))
        assert.equals(2, source.plays)
    end)

    it("does not play on the old thirty-percent trigger", function()
        assert.is_false(meow:tryPlay(fish, 0, function() return 0.10 end))
        assert.equals(0, source.plays)
    end)

    it("resets the cooldown for a new run", function()
        local rareRoll = function() return 0 end
        meow:tryPlay(fish, 20, rareRoll)
        meow:reset()
        assert.is_true(meow:tryPlay(fish, 0, rareRoll))
    end)
end)
