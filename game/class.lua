local Class = {}
Class.__index = Class

function Class:extend()
    local child = {}
    for key, value in pairs(self) do
        if key:find("__", 1, true) == 1 then
            child[key] = value
        end
    end
    child.__index = child
    child.super = self
    return setmetatable(child, self)
end

function Class:new(...)
    local instance = setmetatable({}, self)
    local initializer = rawget(self, "init")
    if initializer then
        initializer(instance, ...)
    end
    return instance
end

function Class:__call(...)
    return self:new(...)
end

return setmetatable(Class, Class)
