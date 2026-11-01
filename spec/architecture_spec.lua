local function countLines(path)
    local file = assert(io.open(path, "r"))
    local count = 0
    for _ in file:lines() do
        count = count + 1
    end
    file:close()
    return count
end

describe("Application architecture", function()
    it("keeps main.lua as a thin LÖVE entry point", function()
        assert.is_true(countLines("main.lua") <= 40)
    end)

    it("provides the application lifecycle through a class", function()
        local App = require("game.app")
        local app = App:new()

        assert.is_function(app.load)
        assert.is_function(app.update)
        assert.is_function(app.draw)
        assert.is_function(app.keypressed)
        assert.is_function(app.keyreleased)
        assert.is_function(app.mousepressed)
    end)
end)
