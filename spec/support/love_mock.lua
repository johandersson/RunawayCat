local LoveMock = {}

local function noOp()
end

function LoveMock.install()
    local soundData = {
        setSample = noOp,
    }
    local files = {}

    _G.love = {
        event = {
            quitRequested = false,
            quit = function()
                love.event.quitRequested = true
            end,
        },
        audio = {
            newSource = function(path)
                return {
                    path = type(path) == "string" and path or "generated",
                    plays = 0,
                    stop = function(self) self.playing = false end,
                    play = function(self)
                        self.playing = true
                        self.plays = self.plays + 1
                    end,
                    setLooping = function(self, looping) self.looping = looping end,
                    setVolume = function(self, volume) self.volume = volume end,
                    setPitch = function(self, pitch) self.pitch = pitch end,
                }
            end,
        },
        filesystem = {
            getInfo = function(path)
                return files[path] and { type = "file", size = #files[path] } or nil
            end,
            read = function(path)
                if not files[path] then
                    return nil, "File not found"
                end
                return files[path]
            end,
            write = function(path, contents)
                files[path] = contents
                return true
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
            newImage = function(path)
                return {
                    path = path,
                    setFilter = noOp,
                }
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
