local Config = require("game.config")
local Hazard = require("game.hazard")

local Dog = Hazard:extend()

function Dog:init(x)
    Hazard.init(self, x, Config.groundY - 52, 80, 52, "dog")
    self.anchorX = x
    self:reset()
end

function Dog:reset()
    self.x = self.anchorX
    self.passed = false
    self.barkTimer = 0
    self.runTimer = 0
end

function Dog:update(dt, player)
    self.barkTimer = math.max(0, self.barkTimer - dt)
    if player.x > self.x + self.w then
        self.passed = true
    end
    if self.passed or player.x + player.w < self.anchorX - 300 then
        return false
    end
    self.x = math.max(self.anchorX - 50, self.x - 75 * dt)
    self.runTimer = self.runTimer + dt * 8
    if self.barkTimer == 0 then
        self.barkTimer = 3
        return true
    end
    return false
end

return Dog
