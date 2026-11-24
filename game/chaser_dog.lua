local Config = require("game.config")
local Hazard = require("game.hazard")

local ChaserDog = Hazard:extend()

function ChaserDog:init()
    Hazard.init(self, -500, Config.groundY - 85, 120, 85, "chaser_dog")
    self.facingRight = true
    self:reset(105, 500)
end

function ChaserDog:reset(playerX, distance)
    self.x = (playerX or 105) - (distance or 500) - self.w
    self.y = Config.groundY - self.h
    self.vy = 0
    self.onGround = true
    self.barkTimer = 0
    self.runTimer = 0
    self.running = false
    self.warned = false
    self.active = false
    self.defeated = false
    self.jumpTargetX = false
    self.jumpOffset = 0
    self.escapes = rawget(self, "escapes") or 0
end

local function containingObstacle(obstacles, x)
    for _, obstacle in ipairs(obstacles) do
        if x > obstacle.x and x < obstacle.x + obstacle.width then
            return obstacle
        end
    end
end

local function jumpObstacles(gaps, hazards)
    local obstacles = {}
    for _, gap in ipairs(gaps) do
        obstacles[#obstacles + 1] = gap
    end
    for _, hazard in ipairs(hazards) do
        if hazard.kind ~= "dog" then
            obstacles[#obstacles + 1] = { x = hazard.x, width = hazard.w }
        end
    end
    return obstacles
end

function ChaserDog:update(dt, player, difficulty, gaps, hazards, random)
    gaps = gaps or {}
    hazards = hazards or {}
    random = random or math.random
    self.barkTimer = math.max(0, self.barkTimer - dt)
    if self.defeated then
        return false
    end
    if player.x < 700 then
        self.running = false
        return false
    end
    if not self.active then
        self.active = true
        self.x = player.x - difficulty.chaserDistance - self.w
    end

    self.running = true
    local speed = player.speed + difficulty.chaserCatchup
    local obstacles = jumpObstacles(gaps, hazards)
    local centerGap = containingObstacle(gaps, self.x + self.w / 2)
    if self.onGround and centerGap then
        self.x = centerGap.x - self.w - 20
    end

    if self.onGround then
        local front = self.x + self.w
        local jumpLead = math.max(45, speed * 0.08)
        for _, obstacle in ipairs(obstacles) do
            local ahead = obstacle.x - front
            if ahead >= 0 and (self.jumpTargetX == false or obstacle.x < self.jumpTargetX) then
                if self.jumpTargetX ~= obstacle.x then
                    self.jumpTargetX = obstacle.x
                    self.jumpOffset = random(-10, 10)
                end
            end
        end
        if self.jumpTargetX then
            local ahead = self.jumpTargetX - front
            if ahead < -20 then
                self.jumpTargetX = false
            elseif ahead >= 0 and ahead <= jumpLead + self.jumpOffset then
                self.jumpTargetX = false
                self.jumpOffset = 0
                self.vy = -780
                self.onGround = false
            end
        end
    end

    self.x = self.x + speed * dt
    if not self.onGround then
        self.vy = self.vy + Config.gravity * dt
        self.y = self.y + self.vy * dt
        local overGap = containingObstacle(gaps, self.x + self.w / 2)
        if self.y + self.h >= Config.groundY and not overGap then
            self.y = Config.groundY - self.h
            self.vy = 0
            self.onGround = true
        end
    end
    self.runTimer = self.runTimer + dt * 10
    local gap = player.x - (self.x + self.w)

    if not self.warned and gap <= difficulty.chaserWarning then
        self.warned = true
        self.barkTimer = 0.55
        return true
    end

    local reachedMiso = self.x + self.w >= player.x + 10
    if reachedMiso and not player.onGround and not self:collidesWith(player:getHitbox()) then
        self.escapes = self.escapes + 1
        self:reset(player.x, difficulty.chaserDistance)
        self.active = true
    end
    return false
end

function ChaserDog:isStompedBy(player, previousBottom)
    if self.defeated or player.vy <= 0 then
        return false
    end
    local hitbox = player:getHitbox()
    local horizontal = hitbox.x + hitbox.w > self.x + 8 and hitbox.x < self.x + self.w - 8
    local currentBottom = player.y + player.h
    return horizontal and previousBottom <= self.y + 16 and currentBottom >= self.y
end

function ChaserDog:defeat()
    self.defeated = true
    self.running = false
    self.barkTimer = 0
end

function ChaserDog:animation()
    if not self.running then return "idle" end
    if self.barkTimer > 0 then return "bark" end
    return "run"
end

return ChaserDog
