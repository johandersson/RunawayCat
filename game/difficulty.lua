local Class = require("game.class")
local Config = require("game.config")

local Difficulty = Class:extend()

local settings = {
    {
        startSpeed = 220,
        endSpeed = 240,
        hazardsPerSection = 0,
        platformRise = 75,
        gapCount = 0,
        gapWidth = 0,
        chaserCatchup = 38,
        chaserDistance = 520,
        chaserWarning = 32,
    },
    {
        startSpeed = 250,
        endSpeed = 270,
        hazardsPerSection = 0,
        platformRise = 90,
        gapCount = 0,
        gapWidth = 0,
        chaserCatchup = 42,
        chaserDistance = 505,
        chaserWarning = 35,
    },
    {
        startSpeed = 280,
        endSpeed = 300,
        hazardsPerSection = 1,
        platformRise = 105,
        gapCount = 1,
        gapWidth = 65,
        chaserCatchup = 46,
        chaserDistance = 490,
        chaserWarning = 38,
    },
    {
        startSpeed = 310,
        endSpeed = 335,
        hazardsPerSection = 1.5,
        platformRise = 120,
        gapCount = 1,
        gapWidth = 85,
        chaserCatchup = 50,
        chaserDistance = 475,
        chaserWarning = 41,
    },
}

local indoorSettings = {
    { startSpeed = 260, endSpeed = 290, hazardsPerSection = 0.5, platformRise = 90, gapCount = 0, gapWidth = 0,
        chaserCatchup = 52, chaserDistance = 470, chaserWarning = 42 },
    { startSpeed = 305, endSpeed = 330, hazardsPerSection = 0.5, platformRise = 100, gapCount = 0, gapWidth = 0,
        chaserCatchup = 55, chaserDistance = 455, chaserWarning = 45 },
    { startSpeed = 345, endSpeed = 370, hazardsPerSection = 1, platformRise = 110, gapCount = 0, gapWidth = 0,
        chaserCatchup = 58, chaserDistance = 440, chaserWarning = 47 },
    { startSpeed = 380, endSpeed = 405, hazardsPerSection = 1.25, platformRise = 118, gapCount = 0, gapWidth = 0,
        chaserCatchup = 61, chaserDistance = 425, chaserWarning = 49 },
    { startSpeed = 415, endSpeed = 440, hazardsPerSection = 1.5, platformRise = 124, gapCount = 0, gapWidth = 0,
        chaserCatchup = 64, chaserDistance = 410, chaserWarning = 51 },
}

local castleSettings = {
    { startSpeed = 300, endSpeed = 325, hazardsPerSection = 0.75, platformRise = 100, gapCount = 0, gapWidth = 0,
        chaserCatchup = 66, chaserDistance = 405, chaserWarning = 53 },
    { startSpeed = 335, endSpeed = 360, hazardsPerSection = 1, platformRise = 108, gapCount = 0, gapWidth = 0,
        chaserCatchup = 69, chaserDistance = 390, chaserWarning = 55 },
    { startSpeed = 370, endSpeed = 395, hazardsPerSection = 1.25, platformRise = 116, gapCount = 1, gapWidth = 70,
        chaserCatchup = 72, chaserDistance = 375, chaserWarning = 57 },
    { startSpeed = 405, endSpeed = 430, hazardsPerSection = 1.5, platformRise = 122, gapCount = 1, gapWidth = 80,
        chaserCatchup = 75, chaserDistance = 360, chaserWarning = 59 },
    { startSpeed = 440, endSpeed = 465, hazardsPerSection = 1.75, platformRise = 128, gapCount = 2, gapWidth = 85,
        chaserCatchup = 78, chaserDistance = 345, chaserWarning = 61 },
}

function Difficulty:init(zoneIndex, levelIndex)
    self.zoneIndex = zoneIndex
    local source = levelIndex == 2 and indoorSettings
        or levelIndex == 3 and castleSettings
        or settings
    for key, value in pairs(source[zoneIndex]) do
        self[key] = value
    end
end

function Difficulty.forZone(zoneIndex, levelIndex)
    local worldCount = levelIndex == 2 and 5 or levelIndex == 3 and 5 or 4
    return Difficulty:new(math.max(1, math.min(worldCount, zoneIndex)), levelIndex)
end

function Difficulty:speedAt(x)
    local localX = (x - (self.zoneIndex - 1) * Config.zoneWidth) / Config.zoneWidth
    local progress = math.max(0, math.min(1, localX))
    return self.startSpeed + (self.endSpeed - self.startSpeed) * progress
end

return Difficulty
