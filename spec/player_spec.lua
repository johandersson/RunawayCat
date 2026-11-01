local Player = require("game.player")

describe("Player", function()
    it("buffers a jump and performs it while grounded", function()
        local player = Player:new(100, 528)

        player:requestJump()
        local jumped = player:updateJump(1 / 60)

        assert.is_true(jumped)
        assert.is_false(player.onGround)
        assert.equals(-740, player.vy)
    end)

    it("allows a short coyote-time jump after leaving a ledge", function()
        local player = Player:new(100, 528)
        player.onGround = false
        player.coyoteTimer = 0.08

        player:requestJump()
        assert.is_true(player:updateJump(1 / 60))
    end)

    it("cuts upward velocity when jump is released", function()
        local player = Player:new(100, 528)
        player.vy = -600

        player:releaseJump()

        assert.equals(-312, player.vy)
    end)
end)
