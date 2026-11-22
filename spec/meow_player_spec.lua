local MeowPlayer = require("game.meow_player")

describe("Life-loss meows", function()
    local source
    local meow
    before_each(function()
        source = {
            plays = 0,
            stops = 0,
            setVolume = function(self, volume) self.volume = volume end,
            stop = function(self) self.stops = self.stops + 1 end,
            play = function(self) self.plays = self.plays + 1 end,
        }
        meow = MeowPlayer:new(source)
    end)

    it("raises the meow above its former quiet level", function()
        assert.is_true(source.volume >= 0.50 and source.volume <= 1)
    end)

    it("plays on every life loss without randomness or a cooldown", function()
        meow:play()
        meow:play()
        assert.equals(2, source.plays)
        assert.equals(2, source.stops)
    end)
end)
