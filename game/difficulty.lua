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

local indoorSettings = {
    { startSpeed = 450, endSpeed = 458, hazardsPerSection = 1, platformRise = 100, gapCount = 0, gapWidth = 0 },
    { startSpeed = 460, endSpeed = 468, hazardsPerSection = 1.25, platformRise = 106, gapCount = 0, gapWidth = 0 },
    { startSpeed = 470, endSpeed = 478, hazardsPerSection = 1.5, platformRise = 112, gapCount = 0, gapWidth = 0 },
    { startSpeed = 480, endSpeed = 488, hazardsPerSection = 1.75, platformRise = 118, gapCount = 0, gapWidth = 0 },
    { startSpeed = 490, endSpeed = 500, hazardsPerSection = 2, platformRise = 124, gapCount = 0, gapWidth = 0 },
}

function Difficulty:init(zoneIndex, levelIndex)
    self.zoneIndex = zoneIndex
    local source = levelIndex == 2 and indoorSettings or settings
    for key, value in pairs(source[zoneIndex]) do
        self[key] = value
    end
end

function Difficulty.forZone(zoneIndex, levelIndex)
    local worldCount = levelIndex == 2 and 5 or 4
    return Difficulty:new(math.max(1, math.min(worldCount, zoneIndex)), levelIndex)
end

function Difficulty:speedAt(x)
    local localX = (x - (self.zoneIndex - 1) * Config.zoneWidth) / Config.zoneWidth
    local progress = math.max(0, math.min(1, localX))
    return self.startSpeed + (self.endSpeed - self.startSpeed) * progress
end

return Difficulty
