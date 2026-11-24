local Class = require("game.class")
local Config = require("game.config")

local Castle = Class:extend()

function Castle:init(graphics, cache)
    self.graphics = graphics
    self.cache = cache
end

function Castle:render(area)
    local g = self.graphics
    g.setColor(0.18, 0.17, 0.23)
    g.rectangle("fill", 0, 0, 640, Config.groundY)
    g.setColor(0.34, 0.32, 0.39)
    for row = 0, 8 do
        for column = -1, 8 do
            local x = column * 82 + row % 2 * 41
            g.rectangle("line", x, row * 66, 82, 66)
        end
    end

    if area == "courtyard" then
        g.setColor(0.42, 0.43, 0.48)
        g.rectangle("fill", 55, 225, 150, 310)
        g.rectangle("fill", 435, 225, 150, 310)
        for x = 55, 535, 76 do
            g.rectangle("fill", x, 190, 45, 55)
        end
        g.setColor(0.12, 0.13, 0.18)
        g.rectangle("fill", 255, 315, 130, 220, 65, 65)
    elseif area == "great_hall" then
        g.setColor(0.56, 0.12, 0.17)
        g.polygon("fill", 70, 80, 200, 115, 190, 390, 80, 390)
        g.polygon("fill", 570, 80, 440, 115, 450, 390, 560, 390)
        g.setColor(0.87, 0.70, 0.29)
        g.rectangle("fill", 290, 290, 60, 245)
        g.circle("fill", 320, 275, 45)
    elseif area == "armory" then
        for i = 0, 4 do
            local x = 70 + i * 120
            g.setColor(0.64, 0.67, 0.72)
            g.rectangle("fill", x, 245, 34, 200, 15, 15)
            g.circle("fill", x + 17, 220, 29)
            g.setColor(0.34, 0.20, 0.13)
            g.rectangle("fill", x - 12, 445, 58, 90)
        end
    elseif area == "dungeon" then
        g.setColor(0.08, 0.09, 0.13)
        for i = 0, 2 do
            local x = 55 + i * 210
            g.rectangle("fill", x, 170, 150, 365, 60, 60)
            g.setColor(0.44, 0.45, 0.50)
            for bar = 1, 4 do
                g.rectangle("fill", x + bar * 28, 210, 8, 325)
            end
            g.setColor(0.08, 0.09, 0.13)
        end
    else
        g.setColor(0.54, 0.28, 0.11)
        for i = 0, 3 do
            g.rectangle("fill", 55 + i * 145, 385 - i % 2 * 75, 120, 150 + i % 2 * 75, 8, 8)
        end
        g.setColor(0.96, 0.73, 0.19)
        for i = 0, 18 do
            g.circle("fill", 35 + (i * 83) % 570, 490 - (i % 4) * 13, 9)
        end
    end
end

function Castle:draw(area, cameraX)
    local sprite = self.cache:get("castle:" .. area, 640, Config.groundY, function()
        self:render(area)
    end)
    self.graphics.setColor(1, 1, 1)
    local offset = (cameraX * 0.24) % 640
    for i = -1, 2 do
        self.graphics.draw(sprite, i * 640 - offset, 0)
    end
end

return Castle
