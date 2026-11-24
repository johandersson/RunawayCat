local Class = require("game.class")
local Config = require("game.config")
local Difficulty = require("game.difficulty")
local Dog = require("game.dog")
local Food = require("game.food")
local Hazard = require("game.hazard")
local Platform = require("game.platform")
local Zone = require("game.zone")

local Level = Class:extend()

function Level:init(random, index)
    self.random = random or math.random
    self.index = index or 1
    self.zones = Zone.defaults(self.index)
    self.sectionCount = #self.zones * 4
    self.finishX = (self.sectionCount + 1) * Config.sectionWidth
    self.homeX = self.finishX + 550
    self.platforms = {}
    self.hazards = {}
    self.foods = {}
    self.gaps = {}
    self.dog = false
end

function Level:getDifficulty(zoneIndex)
    return Difficulty.forZone(zoneIndex, self.index)
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
    local zoneIndex = math.min(#self.zones, math.floor(x / Config.zoneWidth) + 1)
    local difficulty = self:getDifficulty(zoneIndex)
    local zoneSection = section % 4
    local shouldAddGap = section < self.sectionCount
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

    local indoor = self.index == 2
    local castle = self.index == 3
    local shouldAddMainHazard = castle
        or indoor and (zoneIndex >= 3 or zoneSection % 2 == 1)
        or not indoor and zoneIndex >= 3
    if section < self.sectionCount and shouldAddMainHazard and not shouldAddGap then
        local kinds = {
            { "crate", 36, 34 },
            { "thorns", 44, 18 },
            { "log", 45, 24 },
        }
        if indoor then
            kinds = {
                { "toy", 32, 27 }, { "spill", 44, 12 }, { "books", 38, 32 },
                { "basket", 40, 34 }, { "mousetrap", 40, 16 },
            }
        elseif castle then
            kinds = {
                { "barrel", 38, 34 }, { "shield", 34, 35 }, { "chains", 42, 17 },
                { "spikes", 44, 18 }, { "treasure", 42, 32 },
            }
        end
        local choice = kinds[(indoor or castle) and zoneIndex or ((section + zoneIndex) % #kinds) + 1]
        self:addHazard(x + 405, Config.groundY - choice[3], choice[2], choice[3], choice[1])
    end

    if castle and zoneIndex >= 4 and section < self.sectionCount and zoneSection == 1 then
        self:addHazard(x + 92, Config.groundY - 18, 40, 18, "spikes")
    elseif indoor and zoneIndex >= 4 and section < self.sectionCount and zoneSection >= 7 - zoneIndex then
        self:addHazard(x + 92, Config.groundY - 22, 32, 22, "toy")
    elseif not indoor and not castle and zoneIndex >= 3 and section % 2 == 0 then
        self:addHazard(x + 92, Config.groundY - 18, 40, 18, "thorns")
    end

    self:addFood(x + 105, Config.groundY - 60, section % 3 == 2 and "cake" or "fish")
end

function Level:build()
    self.platforms = {}
    self.hazards = {}
    self.foods = {}
    self.gaps = {}
    self.dog = false

    for section = 0, self.sectionCount do
        self:addSection(section)
    end

    self:addPlatform(self.finishX - 250, Config.groundY, self.homeX + 300 - (self.finishX - 250))
    self:addFood(self.finishX - 180, Config.groundY - 65, "cake")
    self:addFood(self.finishX - 120, Config.groundY - 90, "milk")
    self:addFood(self.finishX - 60, Config.groundY - 65, "cake")
    self.dog = Dog:new(self.finishX - 220)
    table.insert(self.hazards, self.dog)
    return self
end

return Level
