local Class = require("game.class")

local DogSprite = Class:extend()

function DogSprite:init(graphics, cache)
    self.graphics = graphics
    self.frames = { idle = {}, run = {}, bark = {} }
    for animation, count in pairs({ idle = 1, run = 5, bark = 3 }) do
        for frame = 1, count do
            local name = animation == "idle" and "Shepherd_default"
                or "Shepherd_" .. animation .. "_" .. frame
            local path = "assets/sprites/dog/" .. name .. ".png"
            self.frames[animation][frame] = cache:get("image:" .. path, function()
                local image = graphics.newImage(path)
                image:setFilter("nearest", "nearest")
                return image
            end)
        end
    end
end

function DogSprite:draw(dog, cameraX)
    local frames = self.frames[dog:animation()]
    local image = frames[math.floor(dog.runTimer) % #frames + 1]
    local scale = dog.h / 17
    self.graphics.setColor(1, 1, 1)
    -- The source faces left; align its opaque x=2..25, y=1..17 bounds.
    self.graphics.draw(image, dog.x - cameraX, dog.y, 0, scale, scale, 2, 1)
end

return DogSprite
