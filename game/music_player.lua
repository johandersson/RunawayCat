local Class = require("game.class")

local MusicPlayer = Class:extend()

function MusicPlayer:init(source, volume)
    self.source = source
    self.volume = volume or 0.32
end

function MusicPlayer:play()
    self.source:setLooping(true)
    self.source:setVolume(self.volume)
    self.source:play()
end

function MusicPlayer:stop()
    self.source:stop()
end

return MusicPlayer
