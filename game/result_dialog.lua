local Class = require("game.class")

local ResultDialog = Class:extend()

function ResultDialog:init()
    self.selected = "restart"
    self.buttons = {
        { action = "restart", label = "Spela igen", x = 350, y = 440, w = 270, h = 65 },
        { action = "exit", label = "Avsluta", x = 660, y = 440, w = 270, h = 65 },
    }
end

function ResultDialog:keypressed(key)
    if key == "left" or key == "right" or key == "tab" then
        self.selected = self.selected == "restart" and "exit" or "restart"
    elseif key == "return" then
        return self.selected
    elseif key == "r" then
        return "restart"
    elseif key == "escape" then
        return "exit"
    end
end

function ResultDialog:mousepressed(x, y)
    for _, button in ipairs(self.buttons) do
        if x >= button.x and x <= button.x + button.w
            and y >= button.y and y <= button.y + button.h then
            self.selected = button.action
            return button.action
        end
    end
end

return ResultDialog
