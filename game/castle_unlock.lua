local Class = require("game.class")

local CastleUnlock = Class:extend()

CastleUnlock.scoreRequirement = 20000

function CastleUnlock:init(filesystem, filename)
    self.filesystem = filesystem
    self.filename = filename or "castle-unlocked.txt"
    self.unlocked = false
end

function CastleUnlock:load()
    if not self.filesystem.getInfo(self.filename) then
        self.unlocked = false
        return false
    end

    local contents, readError = self.filesystem.read(self.filename)
    if not contents then
        error("Could not read castle unlock: " .. tostring(readError))
    end
    self.unlocked = contents == "unlocked"
    return self.unlocked
end

function CastleUnlock:qualifies(score)
    return score > self.scoreRequirement
end

function CastleUnlock:isUnlocked()
    return self.unlocked
end

function CastleUnlock:unlock()
    local success, writeError = self.filesystem.write(self.filename, "unlocked")
    if not success then
        error("Could not save castle unlock: " .. tostring(writeError))
    end
    self.unlocked = true
end

return CastleUnlock
