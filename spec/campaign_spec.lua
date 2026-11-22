local App = require("game.app")
local LoveMock = require("spec.support.love_mock")

local function upvalue(fn, name, visited)
    visited = visited or {}
    if visited[fn] then
        return nil
    end
    visited[fn] = true
    for i = 1, 100 do
        local key, value = debug.getupvalue(fn, i)
        if not key then
            break
        end
        if key == name then
            return value
        end
        if type(value) == "function" then
            local found = upvalue(value, name, visited)
            if found ~= nil then
                return found
            end
        end
    end
end

local function completeLevel(app)
    local player = assert(upvalue(App.update, "player"))
    local level = assert(upvalue(App.update, "level"))
    player.x = level.finishX
    app:update(1 / 60)
    assert.equals("homecoming", app:getStatus().state)
    for _ = 1, 500 do
        app:update(1 / 60)
        if app:getStatus().state ~= "homecoming" then
            return
        end
    end
    error("Homecoming did not finish")
end

describe("Two-level campaign", function()
    local app

    before_each(function()
        LoveMock.install()
        app = App:new()
        app:load()
        app:keypressed("return")
    end)

    it("enters the indoor adventure after the outdoor homecoming", function()
        local lives = assert(upvalue(App.update, "lives"))
        lives:lose()
        completeLevel(app)

        local status = app:getStatus()
        assert.equals(2, status.levelIndex)
        assert.equals("playing", status.state)
        assert.equals(2, status.lives)
        assert.is_true(status.score >= 1000)
        assert.equals(5, status.worldCount)
    end)

    it("finishes only after completing the indoor adventure", function()
        completeLevel(app)
        completeLevel(app)

        assert.equals("won", app:getStatus().state)
        assert.equals(2, app:getStatus().levelIndex)
        app:keypressed("r")
        assert.equals(1, app:getStatus().levelIndex)
        assert.equals(3, app:getStatus().lives)
        assert.equals(0, app:getStatus().score)
    end)

    it("renders every indoor world and its hazards through the existing cache", function()
        completeLevel(app)
        local player = assert(upvalue(App.update, "player"))
        for world = 1, 5 do
            player.x = (world - 1) * 2800 + 200
            for _ = 1, 120 do
                app:update(1 / 60)
            end
            assert.has_no.errors(function()
                app:draw()
            end)
        end
    end)

    it("changes soundtrack on entering the house and restores it on restart", function()
        local music = assert(upvalue(App.update, "music"))
        local outdoor = music.source
        assert.equals("assets/music/retro-run.wav", outdoor.path)

        completeLevel(app)
        local indoor = music.source
        assert.equals("assets/music/retro-home.mp3", indoor.path)
        assert.is_false(outdoor.playing)
        assert.is_true(indoor.playing)
        assert.equals(0.90, indoor.pitch)

        completeLevel(app)
        app:keypressed("r")
        assert.is_true(outdoor == music.source)
        assert.is_false(indoor.playing)
        assert.is_true(outdoor.playing)
        assert.equals(1, outdoor.pitch)
        assert.is_true(upvalue(App.update, "meow").source.volume < outdoor.volume)
    end)
end)
