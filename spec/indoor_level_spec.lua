local Config = require("game.config")
local Level = require("game.level")
local Player = require("game.player")

describe("Indoor level", function()
    it("builds five distinct worlds inside Miso's home", function()
        local level = Level:new(nil, 2):build()

        assert.equals(2, level.index)
        assert.equals(5, #level.zones)
        assert.same({ "hall", "kitchen", "library", "laundry", "attic" }, {
            level.zones[1].room, level.zones[2].room, level.zones[3].room,
            level.zones[4].room, level.zones[5].room,
        })
        assert.equals(5 * Config.zoneWidth + Config.sectionWidth, level.finishX)
        assert.equals(level.finishX + 550, level.homeX)
    end)

    it("uses increasingly difficult but jumpable indoor obstacles", function()
        local level = Level:new(nil, 2):build()
        local allowed = { toy = true, spill = true, books = true, basket = true, mousetrap = true }
        local counts = { 0, 0, 0, 0, 0 }

        for _, hazard in ipairs(level.hazards) do
            assert.is_true(allowed[hazard.kind])
            assert.is_true(hazard.w <= 45 and hazard.h <= 36)
            local world = math.floor(hazard.x / Config.zoneWidth) + 1
            counts[world] = counts[world] + 1
        end
        for world = 1, 5 do
            assert.is_true(counts[world] > 0)
            local jumpHeight = Config.jumpVelocity ^ 2 / (2 * Config.gravity)
            assert.is_true(level:getDifficulty(world).platformRise < jumpHeight)
            if world > 1 then
                assert.is_true(counts[world] >= counts[world - 1])
                assert.is_true(level:getDifficulty(world).startSpeed > level:getDifficulty(world - 1).startSpeed)
            end
        end
        assert.is_true(level:getDifficulty(1).startSpeed >= Level:new():getDifficulty(4).endSpeed)
        assert.is_true(level:getDifficulty(5).endSpeed <= 500)
    end)

    it("keeps indoor floors and respawn points safe in all five worlds", function()
        local level = Level:new(nil, 2):build()
        assert.equals(0, #level.gaps)
        for world = 1, 5 do
            local checkpoint = (world - 1) * Config.zoneWidth + 200
            local safe = { x = checkpoint + 10, y = Config.groundY - 51, w = 46, h = 48 }
            for _, hazard in ipairs(level.hazards) do
                assert.is_false(hazard:collidesWith(safe))
            end
        end
        for section = 0, 20 do
            local x = section * Config.sectionWidth
            local covered = false
            for _, platform in ipairs(level.platforms) do
                if platform.y == Config.groundY and platform.x <= x
                    and platform.x + platform.w >= x + Config.sectionWidth then
                    covered = true
                end
            end
            assert.is_true(covered)
        end
    end)

    it("can traverse all five worlds with the existing player physics", function()
        for _, dt in ipairs({ 1 / 60, 1 / 30 }) do
            local level = Level:new(nil, 2):build()
            local player = Player:new(105, Config.groundY - 58)
            for _ = 1, 4000 do
                local _, world = require("game.zone").at(level.zones, player.x)
                if player.onGround then
                    for _, hazard in ipairs(level.hazards) do
                        local ahead = hazard.x - (player.x + player.w)
                        if ahead >= 0 and ahead < 75 then
                            player:requestJump()
                            break
                        end
                    end
                end
                player:updateTimers(dt)
                player:updateJump(0)
                local bottom = player:move(dt, level:getDifficulty(world):speedAt(player.x))
                if player.vy >= 0 then
                    for _, platform in ipairs(level.platforms) do
                        if platform:canLand(player, bottom) then
                            player:land(platform.y)
                            break
                        end
                    end
                end
                for _, hazard in ipairs(level.hazards) do
                    assert.is_false(hazard:collidesWith(player:getHitbox()),
                        "Collision with " .. hazard.kind .. " at " .. hazard.x .. " (dt=" .. dt .. ")")
                end
                assert.is_true(player.y < Config.groundY)
                if player.x >= level.finishX then
                    break
                end
            end
            assert.is_true(player.x >= level.finishX)
        end
    end)
end)
