local Class = require("game.class")

local MeowPlayer = Class:extend()

function MeowPlayer:init(source)
    self.source = source
    self.source:setVolume(0.60)
end

function MeowPlayer:play()
    self.source:stop()
    self.source:play()
end

return MeowPlayer
