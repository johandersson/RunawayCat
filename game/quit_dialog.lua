local Class = require("game.class")

local QuitDialog = Class:extend()

function QuitDialog:init()
    self.selected = "cancel"
    self.buttons = {
        { action = "quit", label = "Ja, avsluta", x = 350, y = 440, w = 270, h = 65 },
        { action = "cancel", label = "Nej, fortsätt", x = 660, y = 440, w = 270, h = 65 },
    }
end

function QuitDialog:keypressed(key)
    if key == "left" or key == "right" or key == "tab" then
        self.selected = self.selected == "quit" and "cancel" or "quit"
    elseif key == "return" then
        return self.selected
    elseif key == "escape" then
        return "cancel"
    end
end

function QuitDialog:mousepressed(x, y)
    for _, button in ipairs(self.buttons) do
        if x >= button.x and x <= button.x + button.w
            and y >= button.y and y <= button.y + button.h then
            self.selected = button.action
            return button.action
        end
    end
end

return QuitDialog
