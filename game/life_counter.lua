local Class = require("game.class")

local LifeCounter = Class:extend()
local EXTRA_LIFE_INTERVAL = 2000

function LifeCounter:init()
    self:reset()
end

function LifeCounter:reset()
    self.count = 3
    self.nextThreshold = EXTRA_LIFE_INTERVAL
end

function LifeCounter:lose()
    self.count = math.max(0, self.count - 1)
    return self:isGameOver()
end

function LifeCounter:remaining()
    return self.count
end

function LifeCounter:isGameOver()
    return self.count == 0
end

function LifeCounter:awardForScore(score)
    local awarded = 0
    while score >= self.nextThreshold do
        self.count = self.count + 1
        awarded = awarded + 1
        self.nextThreshold = self.nextThreshold + EXTRA_LIFE_INTERVAL
    end
    return awarded
end

function LifeCounter:nextAwardScore()
    return self.nextThreshold
end

return LifeCounter
