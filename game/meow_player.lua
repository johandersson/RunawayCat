local Class = require("game.class")

local MeowPlayer = Class:extend()

function MeowPlayer:init(source)
    self.source = source
    self.source:setVolume(0.10)
    self:reset()
end

function MeowPlayer:reset()
    self.nextTime = 0
end

function MeowPlayer:tryPlay(food, time, random)
    if time < self.nextTime or not food:shouldMeow(random) then
        return false
    end
    self.nextTime = time + 12
    self.source:stop()
    self.source:play()
    return true
end

return MeowPlayer
