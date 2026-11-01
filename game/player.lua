local Class = require("game.class")
local Config = require("game.config")
local Util = require("game.util")

local Player = Class:extend()

function Player:init(x, y)
    self.x = x
    self.y = y
    self.w = 66
    self.h = 58
    self.vy = 0
    self.speed = 260
    self.onGround = true
    self.coyoteTimer = 0
    self.jumpBuffer = 0
    self.runTimer = 0
    self.squash = 0
    self.invulnerable = 0
end

function Player:requestJump()
    self.jumpBuffer = 0.13
end

function Player:releaseJump()
    if self.vy < -260 then
        self.vy = self.vy * 0.52
    end
end

function Player:updateTimers(dt)
    self.jumpBuffer = math.max(0, self.jumpBuffer - dt)
    self.invulnerable = math.max(0, self.invulnerable - dt)
    if self.onGround then
        self.coyoteTimer = 0.11
    else
        self.coyoteTimer = math.max(0, self.coyoteTimer - dt)
    end
end

function Player:updateJump(dt)
    if self.onGround then
        self.coyoteTimer = 0.11
    end
    self.jumpBuffer = math.max(0, self.jumpBuffer - dt)
    if self.jumpBuffer > 0 and self.coyoteTimer > 0 then
        self.vy = Config.jumpVelocity
        self.onGround = false
        self.coyoteTimer = 0
        self.jumpBuffer = 0
        self.squash = -0.16
        return true
    end
    return false
end

function Player:move(dt, speed)
    local previousBottom = self.y + self.h
    self.speed = speed
    self.runTimer = self.runTimer + dt * (self.speed / 70)
    self.x = self.x + self.speed * dt
    self.vy = self.vy + Config.gravity * dt
    self.y = self.y + self.vy * dt
    self.onGround = false
    self.squash = Util.lerp(self.squash, 0, math.min(1, dt * 10))
    return previousBottom
end

function Player:land(y)
    self.y = y - self.h
    self.vy = 0
    self.onGround = true
    self.squash = 0.12
end

function Player:getHitbox()
    return {
        x = self.x + 10,
        y = self.y + 7,
        w = self.w - 20,
        h = self.h - 10,
    }
end

return Player
