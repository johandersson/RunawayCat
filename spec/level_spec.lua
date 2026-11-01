local Level = require("game.level")

local function hazardsInZone(level, zoneIndex)
    local startX = (zoneIndex - 1) * 2800
    local endX = zoneIndex * 2800
    local count = 0
    for _, hazard in ipairs(level.hazards) do
        if hazard.x >= startX and hazard.x < endX then
            count = count + 1
        end
    end
    return count
end

describe("Level difficulty progression", function()
    local level

    before_each(function()
        level = Level:new()
        level:build()
    end)

    it("makes home quarters noticeably forgiving", function()
        local easy = level:getDifficulty(1)

        assert.is_true(easy.startSpeed <= 275)
        assert.is_true(hazardsInZone(level, 1) <= 2)
    end)

    it("increases every major difficulty lever by zone", function()
        for zoneIndex = 2, 4 do
            local previous = level:getDifficulty(zoneIndex - 1)
            local current = level:getDifficulty(zoneIndex)

            assert.is_true(current.startSpeed > previous.startSpeed)
            assert.is_true(current.hazardsPerSection >= previous.hazardsPerSection)
            assert.is_true(current.platformRise > previous.platformRise)
        end
    end)

    it("restores safely jumpable holes with progressive difficulty", function()
        local gapsByZone = { 0, 0, 0, 0 }
        local widestByZone = { 0, 0, 0, 0 }

        for _, gap in ipairs(level.gaps) do
            local zoneIndex = math.floor(gap.x / 2800) + 1
            gapsByZone[zoneIndex] = gapsByZone[zoneIndex] + 1
            widestByZone[zoneIndex] = math.max(widestByZone[zoneIndex], gap.width)
            assert.is_true(gap.width <= 130)
        end

        assert.same({ 0, 1, 2, 3 }, gapsByZone)
        assert.is_true(widestByZone[2] < widestByZone[3])
        assert.is_true(widestByZone[3] < widestByZone[4])
    end)

    it("keeps the start of every environment safe for respawning", function()
        for zoneIndex = 1, 4 do
            local checkpointX = (zoneIndex - 1) * 2800 + 200
            for _, gap in ipairs(level.gaps) do
                assert.is_false(checkpointX >= gap.x and checkpointX <= gap.x + gap.width)
            end
        end
    end)

    it("contains all four environments and a reachable finish", function()
        assert.equals(4, #level.zones)
        assert.is_true(level.finishX > level.zones[4].startX)
        assert.is_true(#level.platforms > 0)
        assert.is_true(#level.foods > 0)
    end)

    it("provides continuous ground from the finish to the family home", function()
        local Config = require("game.config")
        local covered = false

        for _, platform in ipairs(level.platforms) do
            if platform.y == Config.groundY
                and platform.x <= level.finishX
                and platform.x + platform.w >= Config.homeX + 300
            then
                covered = true
                break
            end
        end

        assert.is_true(covered)
    end)

    it("never generates the removed red fire hydrant", function()
        for _, hazard in ipairs(level.hazards) do
            assert.not_equals("hydrant", hazard.kind)
        end
    end)

    it("reserves hazards for the two hardest environments", function()
        assert.equals(0, hazardsInZone(level, 1))
        assert.equals(0, hazardsInZone(level, 2))
        assert.is_true(hazardsInZone(level, 3) > 0)
        assert.is_true(hazardsInZone(level, 4) > 0)
    end)

    it("does not stack a main ground hazard directly before a hole", function()
        for _, gap in ipairs(level.gaps) do
            for _, hazard in ipairs(level.hazards) do
                assert.is_false(hazard.x >= gap.x - 120 and hazard.x < gap.x + gap.width)
            end
        end
    end)

    it("keeps every hard-level hazard small", function()
        for _, hazard in ipairs(level.hazards) do
            assert.is_true(hazard.w <= 45)
            assert.is_true(hazard.h <= 36)
        end
    end)
end)
