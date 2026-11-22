local Class = require("game.class")

local Zone = Class:extend()

function Zone:init(properties)
    for key, value in pairs(properties) do
        self[key] = value
    end
end

local definitions = {
    {
        name = "Hemkvarteren",
        startX = 0,
        skyTop = { 0.48, 0.82, 0.98 },
        skyBottom = { 0.87, 0.96, 1.0 },
        ground = { 0.33, 0.68, 0.30 },
        dirt = { 0.45, 0.30, 0.18 },
        accent = { 0.94, 0.37, 0.35 },
    },
    {
        name = "Viskskogen",
        startX = 2800,
        skyTop = { 0.34, 0.69, 0.67 },
        skyBottom = { 0.76, 0.91, 0.67 },
        ground = { 0.20, 0.50, 0.24 },
        dirt = { 0.31, 0.23, 0.14 },
        accent = { 0.95, 0.72, 0.27 },
    },
    {
        name = "Stora staden",
        startX = 5600,
        skyTop = { 0.56, 0.61, 0.75 },
        skyBottom = { 0.91, 0.73, 0.62 },
        ground = { 0.34, 0.36, 0.42 },
        dirt = { 0.23, 0.24, 0.28 },
        accent = { 0.30, 0.83, 0.92 },
    },
    {
        name = "Månbergen",
        startX = 8400,
        skyTop = { 0.08, 0.11, 0.25 },
        skyBottom = { 0.35, 0.25, 0.47 },
        ground = { 0.27, 0.36, 0.43 },
        dirt = { 0.18, 0.20, 0.27 },
        accent = { 0.78, 0.69, 1.0 },
    },
}

local indoorDefinitions = {
    { name = "Jättehallen", room = "hall", skyTop = { 0.33, 0.24, 0.35 }, skyBottom = { 0.86, 0.67, 0.53 },
        ground = { 0.68, 0.40, 0.24 }, dirt = { 0.39, 0.24, 0.18 }, accent = { 1.0, 0.76, 0.37 } },
    { name = "Köksriket", room = "kitchen", skyTop = { 0.22, 0.44, 0.47 }, skyBottom = { 0.82, 0.91, 0.78 },
        ground = { 0.60, 0.73, 0.72 }, dirt = { 0.27, 0.40, 0.42 }, accent = { 0.98, 0.64, 0.34 } },
    { name = "Bokdjungeln", room = "library", skyTop = { 0.26, 0.18, 0.32 }, skyBottom = { 0.66, 0.46, 0.38 },
        ground = { 0.52, 0.31, 0.23 }, dirt = { 0.29, 0.18, 0.16 }, accent = { 0.77, 0.92, 0.45 } },
    { name = "Tvättlabyrinten", room = "laundry", skyTop = { 0.27, 0.35, 0.59 }, skyBottom = { 0.75, 0.82, 0.96 },
        ground = { 0.47, 0.53, 0.71 }, dirt = { 0.24, 0.29, 0.45 }, accent = { 0.91, 0.69, 1.0 } },
    { name = "Vindens skattkammare", room = "attic", skyTop = { 0.15, 0.14, 0.25 }, skyBottom = { 0.61, 0.42, 0.35 },
        ground = { 0.53, 0.39, 0.30 }, dirt = { 0.27, 0.22, 0.21 }, accent = { 1.0, 0.84, 0.45 } },
}

function Zone.defaults(levelIndex)
    local zones = {}
    local source = levelIndex == 2 and indoorDefinitions or definitions
    for i, definition in ipairs(source) do
        local copy = {}
        for key, value in pairs(definition) do
            if type(value) == "table" then
                copy[key] = { value[1], value[2], value[3] }
            else
                copy[key] = value
            end
        end
        copy.startX = (i - 1) * 2800
        table.insert(zones, Zone:new(copy))
    end
    return zones
end

function Zone.at(zones, x)
    local index = 1
    for i = 2, #zones do
        if x >= zones[i].startX then
            index = i
        end
    end
    return zones[index], index
end

return Zone
