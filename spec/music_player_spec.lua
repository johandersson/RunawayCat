local MusicPlayer = require("game.music_player")

describe("MusicPlayer", function()
    local source

    before_each(function()
        source = {
            looping = false,
            volume = 0,
            played = false,
            stopped = false,
            pitch = 1,
            setPitch = function(self, value)
                self.pitch = value
            end,
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

    it("plays a slower indoor track and stops the previous source", function()
        local music = MusicPlayer:new(source, 0.28)
        music:play()
        local indoor = {
            setLooping = source.setLooping, setVolume = source.setVolume,
            setPitch = source.setPitch, play = source.play, stop = source.stop,
        }

        music:switch(indoor, 0.90)

        assert.is_true(source.stopped)
        assert.is_true(indoor.played)
        assert.is_true(indoor.looping)
        assert.equals(0.90, indoor.pitch)
        assert.equals(0.28, indoor.volume)
    end)

    it("restores normal speed when switching back outdoors", function()
        local music = MusicPlayer:new(source)
        music:switch(source, 0.90)
        music:switch(source, 1)

        assert.equals(1, source.pitch)
    end)
end)
