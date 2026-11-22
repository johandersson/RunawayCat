local Config = require("game.config")
local Hazard = require("game.hazard")

local Dog = Hazard:extend()

function Dog:init(x)
    Hazard.init(self, x, Config.groundY - 85, 120, 85, "dog")
    self.anchorX = x
    self:reset()
end

function Dog:reset()
    self.x = self.anchorX
    self.passed = false
    self.barkTimer = 0
    self.runTimer = 0
    self.running = false
end

function Dog:update(dt, player)
    self.barkTimer = math.max(0, self.barkTimer - dt)
    if player.x > self.x + self.w then
        self.passed = true
        self.running = false
    end
    if self.passed or (not self.running and player.x + player.w < self.anchorX - 450) then
        return false
    end
    self.running = true
    self.x = self.x - 140 * dt
    self.runTimer = self.runTimer + dt * 10
    if self.barkTimer == 0 then
        self.barkTimer = 3
        return true
    end
    return false
end

function Dog:animation()
    if not self.running then return "idle" end
    if self.barkTimer > 2.7 then return "bark" end
    return "run"
end

return Dog
