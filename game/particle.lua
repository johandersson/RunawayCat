local Class = require("game.class")

local Particle = Class:extend()

function Particle:init(x, y, velocityX, velocityY, color, life, size)
    self.x = x
    self.y = y
    self.vx = velocityX
    self.vy = velocityY
    self.color = color
    self.life = life
    self.maxLife = life
    self.size = size
end

function Particle:update(dt)
    self.life = self.life - dt
    self.vy = self.vy + 500 * dt
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    return self.life > 0
end

return Particle
