local Sprite = require('Components.Sprite')
local Asteroid = {}
Asteroid.__index = Asteroid

function Asteroid.new()
    local self = setmetatable({}, Asteroid)
    self.sprite = Sprite.new({
        spritePath = 'Assets/Asteroid 01 - Explode.png',
        animationFrames = 7,
        frameTime = 0.15,
        isPlaying = true,
        playOnce = true,
        spriteScale = { x = 1, y = 1 },
        speed = 20
    })
    self.speed = math.random(50, 100)
    self.list = {}
    self.spawnRate = math.random(3, 10) 
    self.spawnTimer = 0
    self.warningDuration = 1  -- Duration of the warning before spawning asteroid (in seconds)
    return self
end

-- Warning before spawning asteroids
function Asteroid:spawn()
    local velx, vely = math.random() < 0.5 and -1 or 1, -1

    -- Spawn asteroid outside the screen (left, right, top, or bottom)
    local spawnSide = math.random(1, 4)
    local x, y, warningX, warningY

    if spawnSide == 1 then  -- Spawn to the left of the screen
        x = -50
        y = math.random(0, love.graphics.getHeight())
        warningX = 30  -- Show warning just inside the screen
        warningY = y
        velx = 3  -- Ensure the asteroid moves towards the screen
    elseif spawnSide == 2 then  -- Spawn to the right of the screen
        x = love.graphics.getWidth() + 50
        y = math.random(0, love.graphics.getHeight())
        warningX = love.graphics.getWidth() - 30 -- Show warning just inside the screen
        warningY = y
        velx = -3  -- Ensure the asteroid moves towards the screen
    elseif spawnSide == 3 then  -- Spawn above the screen
        x = math.random(0, love.graphics.getWidth())
        y = -50
        warningX = x
        warningY = 30  -- Show warning just inside the screen
        vely = 3  -- Ensure the asteroid moves towards the screen
    else  -- Spawn below the screen
        x = math.random(0, love.graphics.getWidth())
        y = love.graphics.getHeight() + 50
        warningX = x
        warningY = love.graphics.getHeight() - 30  -- Show warning just inside the screen
        vely = -3  -- Ensure the asteroid moves towards the screen
    end

    local asteroid = {
        sprite = Sprite.new({
            spritePath = 'Assets/Asteroid 01 - Explode.png',
            animationFrames = 7,
            frameTime = 0.15,
            isPlaying = true,
            playOnce = true,
            spriteScale = { x = 1, y = 1 },
            speed = 20
        }),
        x = x,
        y = y,
        velocity = {
            x = math.random() * self.speed * velx,
            y = math.random() * self.speed * vely
        },
        angle = math.rad(math.random(math.pi)),
        scale = math.random(10, 20) / 10,
        isAlive = true,
        spawnWarning = true,  -- Indicates if the warning should be shown
        warningTimer = self.warningDuration,  -- Set the warning timer
        warningX = warningX,  -- Position for the warning
        warningY = warningY
    }

    asteroid.radius = asteroid.sprite.sprite.width * asteroid.scale / 6
    table.insert(self.list, asteroid)
end

function Asteroid:drawWarning(x, y)
    love.graphics.setColor(1, 0, 0, 1)  -- Red warning
    love.graphics.circle("line", x, y, 30)
    love.graphics.print("Incoming!", x - 30, y - 10)
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color
end

function Asteroid:draw()
    for _, asteroid in ipairs(self.list) do
        if asteroid.spawnWarning then
            -- Show the warning at the warning coordinates (inside the screen)
            self:drawWarning(asteroid.warningX, asteroid.warningY)
        else
            -- Draw the asteroid
            asteroid.sprite.x = asteroid.x
            asteroid.sprite.y = asteroid.y
            asteroid.sprite.angle = asteroid.angle
            asteroid.sprite.sprite.spriteScale = { x = asteroid.scale, y = asteroid.scale }
            asteroid.sprite:draw()
            
            if Debugging then
                love.graphics.circle("line", asteroid.x - 6, asteroid.y, asteroid.radius)
            end
        end
    end
end

function Asteroid:move(dt)
    for i = #self.list, 1, -1 do
        local asteroid = self.list[i]
        if asteroid.isAlive and not asteroid.spawnWarning then
            asteroid.x = asteroid.x + asteroid.velocity.x * dt
            asteroid.y = asteroid.y + asteroid.velocity.y * dt

            -- Check if the asteroid has appeared on-screen
            if asteroid.x + asteroid.radius > 0 and asteroid.x - asteroid.radius < love.graphics.getWidth() and
               asteroid.y + asteroid.radius > 0 and asteroid.y - asteroid.radius < love.graphics.getHeight() then
                asteroid.hasAppeared = true  -- Asteroid has appeared on-screen
            end

            -- Remove asteroid if it has moved off-screen after appearing
            if asteroid.hasAppeared and 
              (asteroid.x < -asteroid.radius or asteroid.x > love.graphics.getWidth() + asteroid.radius or
               asteroid.y < -asteroid.radius or asteroid.y > love.graphics.getHeight() + asteroid.radius) then
                table.remove(self.list, i)
            end
        end
    end
end

function Asteroid:collision(hitboxes)
    for i = #self.list, 1, -1 do
        if  self.list[i].isAlive then
            for _, hitbox in ipairs(hitboxes) do
                if hitbox.radius then
                    local distance = math.sqrt(((self.list[i].x - 6) - hitbox.x) ^ 2 + (self.list[i].y - hitbox.y) ^ 2)
                    if distance < self.list[i].radius + hitbox.radius then
                        self.list[i].isAlive = false
                        return true
                    end
                elseif hitbox.width and hitbox.height then
                    if self.list[i].x - 6 < hitbox.x + hitbox.width and
                        self.list[i].x - 6 + self.list[i].sprite.width * self.list[i].scale > hitbox.x and
                        self.list[i].y < hitbox.y + hitbox.height and
                        self.list[i].y + self.list[i].sprite.height * self.list[i].scale > hitbox.y then
                        self.list[i].isAlive = false
                        return true
                    end
                end
            end
        end
    end
    return false
end


function Asteroid:update(dt)
    for i = #self.list, 1, -1 do
        local asteroid = self.list[i]

        -- Handle the warning countdown
        if asteroid.spawnWarning then
            asteroid.warningTimer = asteroid.warningTimer - dt
            if asteroid.warningTimer <= 0 then
                asteroid.spawnWarning = false  -- End the warning and spawn the asteroid
            end
        end

        -- Move and update asteroids
        if not asteroid.isAlive then
            asteroid.sprite:updateAnimation(dt)
        end
        if asteroid.sprite.animation.isPlaying == false then
            table.remove(self.list, i)
        end
    end

    self:move(dt)
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer > self.spawnRate then
        for i = 1, math.random(1, 5) do
            self:spawn()
        end
        self.spawnTimer = 0
        self.spawnRate = math.random(5, 10) 
    end
end

return Asteroid
