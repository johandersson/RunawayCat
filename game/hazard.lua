local Class = require("game.class")
local Util = require("game.util")

local Hazard = Class:extend()

function Hazard:init(x, y, width, height, kind)
    self.x = x
    self.y = y
    self.w = width
    self.h = height
    self.kind = kind
end

function Hazard:collidesWith(hitbox)
    return Util.rectsOverlap(hitbox, self, 2)
end

return Hazard
