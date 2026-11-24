local Class = require("game.class")

local MusicPlayer = Class:extend()

function MusicPlayer:init(source, volume)
    self.source = source
    self.defaultVolume = volume or 0.32
    self.volume = self.defaultVolume
    self.pitch = 1
end

function MusicPlayer:play()
    self.source:setLooping(true)
    self.source:setVolume(self.volume)
    self.source:setPitch(self.pitch)
    self.source:play()
end

function MusicPlayer:stop()
    self.source:stop()
end

function MusicPlayer:switch(source, pitch, volume)
    self:stop()
    self.source = source
    self.pitch = pitch or 1
    self.volume = volume or self.defaultVolume
    self:play()
end

return MusicPlayer
