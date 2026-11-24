local Class = require("game.class")

local UnlockDialog = Class:extend()

function UnlockDialog:init()
    self.selected = "unlock"
    self.buttons = {
        { action = "unlock", label = "Lås upp slottet", x = 310, y = 505, w = 310, h = 65 },
        { action = "decline", label = "Inte nu", x = 660, y = 505, w = 310, h = 65 },
    }
end

function UnlockDialog:keypressed(key)
    if key == "left" or key == "right" or key == "tab" then
        self.selected = self.selected == "unlock" and "decline" or "unlock"
    elseif key == "return" then
        return self.selected
    elseif key == "escape" then
        return "decline"
    end
end

function UnlockDialog:mousepressed(x, y)
    for _, button in ipairs(self.buttons) do
        if x >= button.x and x <= button.x + button.w
            and y >= button.y and y <= button.y + button.h then
            self.selected = button.action
            return button.action
        end
    end
end

return UnlockDialog
