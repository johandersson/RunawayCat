local RenderCache = require("game.render_cache")

describe("RenderCache", function()
    it("renders a canvas only once for the same graphic", function()
        local renders = 0
        local canvases = 0
        local graphics = {
            newCanvas = function(width, height)
                canvases = canvases + 1
                return { width = width, height = height }
            end,
            getCanvas = function()
                return nil
            end,
            setCanvas = function()
            end,
            clear = function()
            end,
            push = function()
            end,
            pop = function()
            end,
            origin = function()
            end,
        }
        local cache = RenderCache:new(graphics)

        local first = cache:get("fish", 64, 64, function()
            renders = renders + 1
        end)
        local second = cache:get("fish", 64, 64, function()
            renders = renders + 1
        end)

        assert.is_true(first == second)
        assert.equals(1, canvases)
        assert.equals(1, renders)
    end)
end)
