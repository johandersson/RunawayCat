local Cache = require("game.cache")
local Class = require("game.class")

local RenderCache = Class:extend()

function RenderCache:init(graphics)
    self.graphics = graphics
    self.cache = Cache:new()
end

function RenderCache:get(key, width, height, renderer)
    return self.cache:get(key, function()
        local graphics = self.graphics
        local previousCanvas = graphics.getCanvas()
        local canvas = graphics.newCanvas(width, height)
        graphics.push("all")
        graphics.setCanvas(canvas)
        graphics.clear(0, 0, 0, 0)
        graphics.origin()

        local succeeded, failure = pcall(renderer)
        graphics.setCanvas(previousCanvas)
        graphics.pop()
        if not succeeded then
            error(failure)
        end
        return canvas
    end)
end

function RenderCache:size()
    return self.cache:size()
end

function RenderCache:clear()
    self.cache:clear()
end

return RenderCache
