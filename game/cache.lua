local Class = require("game.class")
local unpackArguments = table.unpack or unpack

local Cache = Class:extend()

function Cache:init()
    self.values = {}
    self.present = {}
    self.count = 0
end

function Cache:get(key, factory)
    if not self.present[key] then
        self.values[key] = factory()
        self.present[key] = true
        self.count = self.count + 1
    end
    return self.values[key]
end

function Cache:memoize(factory)
    return function(key, ...)
        local arguments = { ... }
        return self:get(key, function()
            return factory(key, unpackArguments(arguments))
        end)
    end
end

function Cache:size()
    return self.count
end

function Cache:clear()
    self.values = {}
    self.present = {}
    self.count = 0
end

return Cache
