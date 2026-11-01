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

function Zone.defaults()
    local zones = {}
    for _, definition in ipairs(definitions) do
        local copy = {}
        for key, value in pairs(definition) do
            if type(value) == "table" then
                copy[key] = { value[1], value[2], value[3] }
            else
                copy[key] = value
            end
        end
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
