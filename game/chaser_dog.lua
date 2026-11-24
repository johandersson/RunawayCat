local Config = require("game.config")
local Hazard = require("game.hazard")

local ChaserDog = Hazard:extend()

function ChaserDog:init()
    Hazard.init(self, -500, Config.groundY - 85, 120, 85, "chaser_dog")
    self.facingRight = true
    self:reset(105, 500)
end

function ChaserDog:reset(playerX, distance)
    self.x = (playerX or 105) - (distance or 500) - self.w
    self.barkTimer = 0
    self.runTimer = 0
    self.running = false
    self.warned = false
    self.active = false
    self.escapes = rawget(self, "escapes") or 0
end

function ChaserDog:update(dt, player, difficulty)
    self.barkTimer = math.max(0, self.barkTimer - dt)
    if player.x < 700 then
        self.running = false
        return false
    end
    if not self.active then
        self.active = true
        self.x = player.x - difficulty.chaserDistance - self.w
    end

    self.running = true
    self.x = self.x + (player.speed + difficulty.chaserCatchup) * dt
    self.runTimer = self.runTimer + dt * 10
    local gap = player.x - (self.x + self.w)

    if not self.warned and gap <= difficulty.chaserWarning then
        self.warned = true
        self.barkTimer = 0.55
        return true
    end

    local reachedMiso = self.x + self.w >= player.x + 10
    if reachedMiso and not player.onGround and not self:collidesWith(player:getHitbox()) then
        self.escapes = self.escapes + 1
        self:reset(player.x, difficulty.chaserDistance)
        self.active = true
    end
    return false
end

function ChaserDog:animation()
    if not self.running then return "idle" end
    if self.barkTimer > 0 then return "bark" end
    return "run"
end

return ChaserDog
