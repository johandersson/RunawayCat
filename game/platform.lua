local Class = require("game.class")
local Config = require("game.config")

local Platform = Class:extend()

function Platform:init(x, y, width, height)
    self.x = x
    self.y = y
    self.w = width
    self.h = height or Config.height - y
end

function Platform:canLand(player, previousBottom)
    local withinX = player.x + player.w - 13 > self.x and player.x + 13 < self.x + self.w
    local nextBottom = player.y + player.h
    return withinX and previousBottom <= self.y + 8 and nextBottom >= self.y
end

return Platform
