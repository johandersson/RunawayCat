local CastleUnlock = require("game.castle_unlock")
local Level = require("game.level")

local function filesystem(initial)
    local files = initial or {}
    return {
        getInfo = function(path)
            return files[path] and { type = "file" } or nil
        end,
        read = function(path)
            return files[path]
        end,
        write = function(path, contents)
            files[path] = contents
            return true
        end,
        files = files,
    }
end

describe("Castle unlock", function()
    it("requires strictly more than 20,000 points", function()
        local unlock = CastleUnlock:new(filesystem())

        assert.is_false(unlock:qualifies(20000))
        assert.is_true(unlock:qualifies(20001))
    end)

    it("persists and reloads an accepted unlock", function()
        local storage = filesystem()
        local first = CastleUnlock:new(storage)
        first:unlock()

        local second = CastleUnlock:new(storage)
        assert.is_true(second:load())
        assert.is_true(second:isUnlocked())
        assert.equals("unlocked", storage.files["castle-unlocked.txt"])
    end)

    it("sets an attainable requirement for the first two levels", function()
        local maximum = 2000
        for levelIndex = 1, 2 do
            local level = Level:new(function()
                return 0
            end, levelIndex):build()
            for _, food in ipairs(level.foods) do
                maximum = maximum + food:collect()
            end
        end

        assert.is_true(maximum > CastleUnlock.scoreRequirement)
    end)
end)
