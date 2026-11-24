local Cache = require("game.cache")
local Dog = require("game.dog")
local ChaserDog = require("game.chaser_dog")
local DogSprite = require("game.dog_sprite")
local Player = require("game.player")
local LoveMock = require("spec.support.love_mock")

describe("Licensed animated dog sprite", function()
    before_each(function() LoveMock.install() end)

    it("caches the decoded images across renderer instances", function()
        local loads = 0
        local newImage = love.graphics.newImage
        love.graphics.newImage = function(path)
            loads = loads + 1
            return newImage(path)
        end
        local cache = Cache:new()
        DogSprite:new(love.graphics, cache)
        DogSprite:new(love.graphics, cache)
        assert.equals(9, loads)
    end)

    it("preserves the left-facing pose and changes from idle to bark and running frames", function()
        local draws = {}
        love.graphics.draw = function(image, x, y, rotation, sx, sy)
            draws[#draws + 1] = { image = image, sx = sx, sy = sy }
        end
        local sprite = DogSprite:new(love.graphics, Cache:new())
        local dog = Dog:new(1000)
        local player = Player:new(760, 532)
        sprite:draw(dog, 0)
        assert.matches("Shepherd_default", draws[1].image.path)
        dog:update(1 / 60, player)
        sprite:draw(dog, 0)
        assert.matches("Shepherd_bark", draws[2].image.path)
        dog:update(0.4, player)
        sprite:draw(dog, 0)
        assert.matches("Shepherd_run", draws[3].image.path)
        dog:update(0.1, player)
        sprite:draw(dog, 0)
        assert.is_true(draws[3].image ~= draws[4].image)
        assert.is_true(draws[4].sx > 0 and draws[4].sy > 0)
    end)

    it("flips the pursuing dog to face right", function()
        local draw
        love.graphics.draw = function(image, x, y, rotation, sx, sy)
            draw = { image = image, sx = sx, sy = sy }
        end
        local sprite = DogSprite:new(love.graphics, Cache:new())

        sprite:draw(ChaserDog:new(), 0)

        assert.matches("Shepherd_default", draw.image.path)
        assert.is_true(draw.sx < 0 and draw.sy > 0)
    end)
end)
