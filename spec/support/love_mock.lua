local LoveMock = {}

local function noOp()
end

function LoveMock.install()
    local source = {
        stop = noOp,
        play = noOp,
        setLooping = noOp,
        setVolume = noOp,
    }
    local soundData = {
        setSample = noOp,
    }

    _G.love = {
        audio = {
            newSource = function()
                return source
            end,
        },
        graphics = {
            arc = noOp,
            circle = noOp,
            clear = noOp,
            draw = noOp,
            ellipse = noOp,
            getCanvas = function()
                return nil
            end,
            getDimensions = function()
                return 1280, 720
            end,
            line = noOp,
            newCanvas = function(width, height)
                return { width = width, height = height }
            end,
            newFont = function(size)
                return { size = size }
            end,
            origin = noOp,
            polygon = noOp,
            pop = noOp,
            print = noOp,
            printf = noOp,
            push = noOp,
            rectangle = noOp,
            rotate = noOp,
            scale = noOp,
            setCanvas = noOp,
            setColor = noOp,
            setDefaultFilter = noOp,
            setFont = noOp,
            setLineWidth = noOp,
            translate = noOp,
        },
        math = {
            random = function(minimum, maximum)
                if minimum and maximum then
                    return math.random(minimum, maximum)
                elseif minimum then
                    return math.random(minimum)
                end
                return math.random()
            end,
            setRandomSeed = math.randomseed,
        },
        sound = {
            newSoundData = function()
                return soundData
            end,
        },
    }

    return _G.love
end

return LoveMock
