local Class = require("game.class")
local Config = require("game.config")

local Difficulty = Class:extend()

local settings = {
    {
        startSpeed = 260,
        endSpeed = 290,
        hazardsPerSection = 0,
        platformRise = 90,
        gapCount = 0,
        gapWidth = 0,
    },
    {
        startSpeed = 305,
        endSpeed = 340,
        hazardsPerSection = 0,
        platformRise = 115,
        gapCount = 1,
        gapWidth = 90,
    },
    {
        startSpeed = 350,
        endSpeed = 390,
        hazardsPerSection = 1,
        platformRise = 140,
        gapCount = 2,
        gapWidth = 110,
    },
    {
        startSpeed = 400,
        endSpeed = 450,
        hazardsPerSection = 1.5,
        platformRise = 160,
        gapCount = 3,
        gapWidth = 130,
    },
}

function Difficulty:init(zoneIndex)
    self.zoneIndex = zoneIndex
    for key, value in pairs(settings[zoneIndex]) do
        self[key] = value
    end
end

function Difficulty.forZone(zoneIndex)
    return Difficulty:new(math.max(1, math.min(4, zoneIndex)))
end

function Difficulty:speedAt(x)
    local localX = (x - (self.zoneIndex - 1) * Config.zoneWidth) / Config.zoneWidth
    local progress = math.max(0, math.min(1, localX))
    return self.startSpeed + (self.endSpeed - self.startSpeed) * progress
end

return Difficulty
