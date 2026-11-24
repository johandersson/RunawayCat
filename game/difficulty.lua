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
        chaserCatchup = 22,
        chaserDistance = 630,
        chaserWarning = 26,
    },
    {
        startSpeed = 250,
        endSpeed = 270,
        hazardsPerSection = 0,
        platformRise = 90,
        gapCount = 0,
        gapWidth = 0,
        chaserCatchup = 25,
        chaserDistance = 610,
        chaserWarning = 28,
    },
    {
        startSpeed = 280,
        endSpeed = 300,
        hazardsPerSection = 1,
        platformRise = 105,
        gapCount = 1,
        gapWidth = 65,
        chaserCatchup = 28,
        chaserDistance = 590,
        chaserWarning = 30,
    },
    {
        startSpeed = 310,
        endSpeed = 335,
        hazardsPerSection = 1.5,
        platformRise = 120,
        gapCount = 1,
        gapWidth = 85,
        chaserCatchup = 31,
        chaserDistance = 570,
        chaserWarning = 32,
    },
}

local indoorSettings = {
    { startSpeed = 260, endSpeed = 290, hazardsPerSection = 0.5, platformRise = 90, gapCount = 0, gapWidth = 0,
        chaserCatchup = 33, chaserDistance = 560, chaserWarning = 34 },
    { startSpeed = 305, endSpeed = 330, hazardsPerSection = 0.5, platformRise = 100, gapCount = 0, gapWidth = 0,
        chaserCatchup = 36, chaserDistance = 540, chaserWarning = 36 },
    { startSpeed = 345, endSpeed = 370, hazardsPerSection = 1, platformRise = 110, gapCount = 0, gapWidth = 0,
        chaserCatchup = 39, chaserDistance = 520, chaserWarning = 38 },
    { startSpeed = 380, endSpeed = 405, hazardsPerSection = 1.25, platformRise = 118, gapCount = 0, gapWidth = 0,
        chaserCatchup = 42, chaserDistance = 500, chaserWarning = 40 },
    { startSpeed = 415, endSpeed = 440, hazardsPerSection = 1.5, platformRise = 124, gapCount = 0, gapWidth = 0,
        chaserCatchup = 45, chaserDistance = 480, chaserWarning = 42 },
}

local castleSettings = {
    { startSpeed = 300, endSpeed = 325, hazardsPerSection = 0.75, platformRise = 100, gapCount = 0, gapWidth = 0,
        chaserCatchup = 47, chaserDistance = 470, chaserWarning = 44 },
    { startSpeed = 335, endSpeed = 360, hazardsPerSection = 1, platformRise = 108, gapCount = 0, gapWidth = 0,
        chaserCatchup = 50, chaserDistance = 450, chaserWarning = 46 },
    { startSpeed = 370, endSpeed = 395, hazardsPerSection = 1.25, platformRise = 116, gapCount = 1, gapWidth = 70,
        chaserCatchup = 53, chaserDistance = 430, chaserWarning = 48 },
    { startSpeed = 405, endSpeed = 430, hazardsPerSection = 1.5, platformRise = 122, gapCount = 1, gapWidth = 80,
        chaserCatchup = 56, chaserDistance = 410, chaserWarning = 50 },
    { startSpeed = 440, endSpeed = 465, hazardsPerSection = 1.75, platformRise = 128, gapCount = 2, gapWidth = 85,
        chaserCatchup = 59, chaserDistance = 390, chaserWarning = 52 },
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
