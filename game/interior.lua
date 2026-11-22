local Class = require("game.class")
local Config = require("game.config")

local Interior = Class:extend()

function Interior:init(graphics, cache)
    self.graphics = graphics
    self.cache = cache
end

function Interior:render(room)
    local g = self.graphics
    g.setColor(1, 1, 1, 0.08)
    for x = 0, 640, 80 do
        g.rectangle("fill", x, 0, 3, Config.groundY)
    end
    g.setColor(0.25, 0.17, 0.14)
    g.rectangle("fill", 0, 535, 640, 55)

    if room == "hall" then
        g.setColor(0.43, 0.25, 0.16)
        g.rectangle("fill", 65, 105, 200, 430, 15, 15)
        g.setColor(0.74, 0.47, 0.28)
        g.rectangle("fill", 83, 123, 164, 270, 8, 8)
        g.setColor(1, 0.81, 0.30)
        g.circle("fill", 225, 355, 9)
        g.setColor(0.53, 0.29, 0.22)
        g.rectangle("fill", 355, 370, 245, 50, 10, 10)
        g.rectangle("fill", 370, 420, 22, 115)
        g.rectangle("fill", 562, 420, 22, 115)
        g.setColor(0.85, 0.68, 0.42)
        g.ellipse("fill", 420, 344, 46, 26)
        g.ellipse("fill", 530, 344, 46, 26)
    elseif room == "kitchen" then
        g.setColor(0.87, 0.93, 0.90)
        g.rectangle("fill", 60, 135, 180, 400, 14, 14)
        g.setColor(0.36, 0.55, 0.57)
        g.rectangle("fill", 73, 320, 154, 5)
        g.rectangle("fill", 205, 170, 8, 80)
        g.rectangle("fill", 205, 350, 8, 80)
        g.setColor(0.53, 0.70, 0.66)
        g.rectangle("fill", 300, 350, 310, 185, 9, 9)
        g.setColor(0.22, 0.28, 0.28)
        g.rectangle("fill", 287, 333, 335, 20, 6, 6)
        g.setColor(0.66, 0.70, 0.76)
        g.rectangle("fill", 370, 260, 130, 73, 22, 22)
        g.setColor(0.80, 0.83, 0.87)
        g.rectangle("fill", 355, 258, 160, 10, 5, 5)
    elseif room == "library" then
        g.setColor(0.40, 0.23, 0.15)
        g.rectangle("fill", 35, 110, 565, 425, 8, 8)
        for row = 0, 2 do
            for book = 0, 10 do
                g.setColor(0.34 + book % 3 * 0.16, 0.33 + book % 2 * 0.15, 0.33 + book % 4 * 0.12)
                g.rectangle("fill", 52 + book * 48, 132 + row * 132 + book % 2 * 13,
                    37, 96 - book % 2 * 13, 3, 3)
                g.setColor(0.97, 0.78, 0.43)
                g.rectangle("fill", 60 + book * 48, 155 + row * 132, 20, 3)
            end
            g.setColor(0.65, 0.39, 0.22)
            g.rectangle("fill", 45, 231 + row * 132, 545, 16)
        end
    elseif room == "laundry" then
        for i = 0, 1 do
            local x = 50 + i * 300
            g.setColor(0.84, 0.87, 0.94)
            g.rectangle("fill", x, 270, 240, 265, 20, 20)
            g.setColor(0.27, 0.32, 0.49)
            g.circle("fill", x + 120, 425, 82)
            g.setColor(0.48, 0.66, 0.81)
            g.circle("fill", x + 120, 425, 60)
            g.setColor(0.91, 0.55, 0.75)
            g.ellipse("fill", x + 118, 440, 38, 25)
            g.setColor(0.27, 0.32, 0.49)
            g.rectangle("fill", x + 20, 295, 85, 16, 5, 5)
            g.circle("fill", x + 195, 307, 16)
        end
        g.setColor(0.78, 0.72, 0.91)
        g.rectangle("fill", 390, 175, 110, 90, 12, 12)
    else
        g.setColor(0.43, 0.29, 0.19)
        g.polygon("fill", 0, 60, 640, 420, 640, 455, 0, 95)
        g.polygon("fill", 640, 60, 0, 420, 0, 455, 640, 95)
        for i = 0, 2 do
            g.setColor(0.59 + i * 0.08, 0.40 + i * 0.04, 0.23)
            g.rectangle("fill", 70 + i * 175, 355 - i % 2 * 95, 150, 180 + i % 2 * 95, 5, 5)
            g.setColor(0.84, 0.68, 0.41)
            g.rectangle("fill", 130 + i * 175, 355 - i % 2 * 95, 20, 180 + i % 2 * 95)
        end
    end
end

function Interior:draw(room, cameraX)
    local sprite = self.cache:get("interior:" .. room, 640, Config.groundY, function()
        self:render(room)
    end)
    self.graphics.setColor(1, 1, 1)
    local offset = (cameraX * 0.28) % 640
    for i = -1, 2 do
        self.graphics.draw(sprite, i * 640 - offset, 0)
    end
end

return Interior
