local QuitDialog = require("game.quit_dialog")

describe("Quit confirmation dialog", function()
    it("defaults to the safe continue choice", function()
        local dialog = QuitDialog:new()

        assert.equals("cancel", dialog.selected)
        assert.equals("cancel", dialog:keypressed("return"))
        assert.is_nil(dialog:keypressed("space"))
        assert.is_nil(dialog:mousepressed(0, 0))
    end)

    it("requires an explicit quit choice", function()
        local dialog = QuitDialog:new()

        dialog:keypressed("left")

        assert.equals("quit", dialog:keypressed("return"))
        assert.equals("quit", dialog:mousepressed(450, 470))
        assert.equals("cancel", dialog:mousepressed(750, 470))
    end)

    it("treats Escape as cancel", function()
        local dialog = QuitDialog:new()

        assert.equals("cancel", dialog:keypressed("escape"))
    end)
end)
