local Config = require("game.config")
local Level = require("game.level")

describe("Castle level", function()
    it("builds five distinct castle areas", function()
        local level = Level:new(nil, 3):build()

        assert.equals(3, level.index)
        assert.equals(5, #level.zones)
        assert.same({ "courtyard", "great_hall", "armory", "dungeon", "treasury" }, {
            level.zones[1].area, level.zones[2].area, level.zones[3].area,
            level.zones[4].area, level.zones[5].area,
        })
        assert.equals(5 * Config.zoneWidth + Config.sectionWidth, level.finishX)
    end)

    it("uses castle hazards and ramps difficulty across all five areas", function()
        local level = Level:new(nil, 3):build()
        local allowed = {
            barrel = true, shield = true, chains = true, spikes = true,
            treasure = true, dog = true,
        }
        local counts = { 0, 0, 0, 0, 0 }

        for _, hazard in ipairs(level.hazards) do
            assert.is_true(allowed[hazard.kind])
            if hazard.kind ~= "dog" then
                local area = math.min(5, math.floor(hazard.x / Config.zoneWidth) + 1)
                counts[area] = counts[area] + 1
                assert.is_true(hazard.w <= 45 and hazard.h <= 36)
            end
        end

        for area = 1, 5 do
            assert.is_true(counts[area] > 0)
            if area > 1 then
                assert.is_true(level:getDifficulty(area).startSpeed
                    > level:getDifficulty(area - 1).startSpeed)
            end
        end
    end)

    it("keeps every respawn point clear", function()
        local level = Level:new(nil, 3):build()

        for area = 1, 5 do
            local checkpoint = (area - 1) * Config.zoneWidth + 200
            local safe = { x = checkpoint + 10, y = Config.groundY - 51, w = 46, h = 48 }
            for _, hazard in ipairs(level.hazards) do
                assert.is_false(hazard:collidesWith(safe))
            end
            for _, gap in ipairs(level.gaps) do
                assert.is_false(checkpoint >= gap.x and checkpoint <= gap.x + gap.width)
            end
        end
    end)
end)
