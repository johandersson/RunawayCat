local UnlockDialog = require("game.unlock_dialog")

describe("Castle unlock dialog", function()
    it("defaults to unlocking and ignores gameplay keys", function()
        local dialog = UnlockDialog:new()

        assert.equals("unlock", dialog.selected)
        assert.is_nil(dialog:keypressed("space"))
        assert.is_nil(dialog:mousepressed(0, 0))
    end)

    it("supports declining with keyboard or mouse", function()
        local dialog = UnlockDialog:new()
        dialog:keypressed("right")

        assert.equals("decline", dialog:keypressed("return"))
        assert.equals("decline", dialog:mousepressed(750, 535))
    end)
end)
