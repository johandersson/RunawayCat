local MusicPlayer = require("game.music_player")

describe("MusicPlayer", function()
    local source

    before_each(function()
        source = {
            looping = false,
            volume = 0,
            played = false,
            stopped = false,
            setLooping = function(self, value)
                self.looping = value
            end,
            setVolume = function(self, value)
                self.volume = value
            end,
            play = function(self)
                self.played = true
            end,
            stop = function(self)
                self.stopped = true
            end,
        }
    end)

    it("configures and starts a quiet looping soundtrack", function()
        local music = MusicPlayer:new(source, 0.35)

        music:play()

        assert.is_true(source.looping)
        assert.equals(0.35, source.volume)
        assert.is_true(source.played)
    end)

    it("can stop the soundtrack", function()
        local music = MusicPlayer:new(source)

        music:stop()

        assert.is_true(source.stopped)
    end)
end)
