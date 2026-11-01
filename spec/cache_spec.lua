local Cache = require("game.cache")

describe("Cache", function()
    it("runs a factory only once for the same key", function()
        local cache = Cache:new()
        local calls = 0

        local first = cache:get("cat", function()
            calls = calls + 1
            return { name = "Miso" }
        end)
        local second = cache:get("cat", function()
            calls = calls + 1
            return { name = "Other" }
        end)

        assert.equals(1, calls)
        assert.is_true(first == second)
    end)

    it("memoizes a functional loader by key", function()
        local cache = Cache:new()
        local calls = 0
        local load = cache:memoize(function(key, suffix)
            calls = calls + 1
            return key .. suffix
        end)

        assert.equals("fish-sprite", load("fish", "-sprite"))
        assert.equals("fish-sprite", load("fish", "-ignored"))
        assert.equals("milk-sprite", load("milk", "-sprite"))
        assert.equals(2, calls)
        assert.equals(2, cache:size())
    end)

    it("can clear all cached resources", function()
        local cache = Cache:new()
        cache:get("music", function()
            return {}
        end)

        cache:clear()

        assert.equals(0, cache:size())
    end)
end)
