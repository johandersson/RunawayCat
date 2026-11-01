local Class = require("game.class")

local Homecoming = Class:extend()

function Homecoming:init(startX, homeX)
    self.x = startX
    self.homeX = homeX
    self.targetX = homeX - 90
    self.currentPhase = "approaching"
    self.hugTimer = 0
    self.finished = false
end

function Homecoming:update(dt)
    if self.currentPhase == "approaching" then
        self.x = math.min(self.targetX, self.x + 180 * dt)
        if self.x >= self.targetX then
            self.currentPhase = "hugging"
        end
    elseif self.currentPhase == "hugging" then
        self.hugTimer = self.hugTimer + dt
        self.finished = self.hugTimer >= 3
    end
end

function Homecoming:phase()
    return self.currentPhase
end

function Homecoming:catX()
    return self.x
end

function Homecoming:hugX()
    return self.targetX
end

function Homecoming:isFinished()
    return self.finished
end

return Homecoming
