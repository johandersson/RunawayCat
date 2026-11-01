local Class = require("game.class")

local Food = Class:extend()
local values = {
    fish = 100,
    milk = 175,
    cake = 250,
}

function Food:init(x, y, kind, bob)
    self.x = x
    self.y = y
    self.kind = kind or "fish"
    self.collected = false
    self.bob = bob or 0
end

function Food:collect()
    if self.collected then
        return 0
    end
    self.collected = true
    return values[self.kind]
end

function Food:shouldMeow(random)
    return self.kind == "fish" and (random or math.random)() < 0.30
end

function Food:getHitbox()
    return { x = self.x - 20, y = self.y - 20, w = 40, h = 40 }
end

return Food
