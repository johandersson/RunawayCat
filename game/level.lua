local Class = require("game.class")
local Config = require("game.config")
local Difficulty = require("game.difficulty")
local Food = require("game.food")
local Hazard = require("game.hazard")
local Platform = require("game.platform")
local Zone = require("game.zone")

local Level = Class:extend()

function Level:init(random)
    self.random = random or math.random
    self.finishX = Config.levelEnd
    self.zones = Zone.defaults()
    self.platforms = {}
    self.hazards = {}
    self.foods = {}
    self.gaps = {}
end

function Level:getDifficulty(zoneIndex)
    return Difficulty.forZone(zoneIndex)
end

function Level:addPlatform(x, y, width, height)
    table.insert(self.platforms, Platform:new(x, y, width, height))
end

function Level:addHazard(x, y, width, height, kind)
    table.insert(self.hazards, Hazard:new(x, y, width, height, kind))
end

function Level:addFood(x, y, kind)
    table.insert(self.foods, Food:new(x, y, kind, self.random() * math.pi * 2))
end

function Level:addGroundSection(x, width, gapWidth)
    if gapWidth <= 0 then
        self:addPlatform(x, Config.groundY, width)
        return
    end

    local gapX = x + 500
    self:addPlatform(x, Config.groundY, gapX - x)
    self:addPlatform(gapX + gapWidth, Config.groundY, x + width - gapX - gapWidth)
    table.insert(self.gaps, { x = gapX, width = gapWidth })
end

function Level:addSection(section)
    local x = section * Config.sectionWidth
    local zoneIndex = math.min(4, math.floor(x / Config.zoneWidth) + 1)
    local difficulty = self:getDifficulty(zoneIndex)
    local zoneSection = section % 4
    local shouldAddGap = section < 16
        and zoneSection > 0
        and zoneSection >= 4 - difficulty.gapCount

    self:addGroundSection(x, Config.sectionWidth, shouldAddGap and difficulty.gapWidth or 0)

    if section > 0 then
        local platformY = Config.groundY - difficulty.platformRise
        local platformX = x + 210
        self:addPlatform(platformX, platformY, 165, 22)
        self:addFood(platformX + 42, platformY - 42, section % 4 == 0 and "cake" or "fish")
        self:addFood(platformX + 105, platformY - 42, "fish")
    end

    local archStart = Config.sectionWidth - 235
    for foodIndex = 0, 3 do
        local foodX = x + archStart + foodIndex * 54
        local height = math.sin(foodIndex / 3 * math.pi) * (45 + zoneIndex * 6)
        self:addFood(foodX, Config.groundY - 72 - height, foodIndex == 2 and "milk" or "fish")
    end

    local shouldAddMainHazard = zoneIndex >= 3
    if section > 0 and section < 16 and shouldAddMainHazard and not shouldAddGap then
        local kinds = {
            { "crate", 36, 34 },
            { "thorns", 44, 18 },
            { "log", 45, 24 },
        }
        local choice = kinds[((section + zoneIndex) % #kinds) + 1]
        self:addHazard(x + 405, Config.groundY - choice[3], choice[2], choice[3], choice[1])
    end

    if zoneIndex >= 3 and section % 2 == 0 then
        self:addHazard(x + 92, Config.groundY - 18, 40, 18, "thorns")
    end

    self:addFood(x + 105, Config.groundY - 60, section % 3 == 2 and "cake" or "fish")
end

function Level:build()
    self.platforms = {}
    self.hazards = {}
    self.foods = {}
    self.gaps = {}

    for section = 0, 16 do
        self:addSection(section)
    end

    self:addPlatform(11650, Config.groundY, Config.homeX + 300 - 11650)
    self:addFood(11720, Config.groundY - 65, "cake")
    self:addFood(11780, Config.groundY - 90, "milk")
    self:addFood(11840, Config.groundY - 65, "cake")
    return self
end

return Level
