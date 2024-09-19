local Ship = require 'Objects.Ship'
local Bullet = require 'Objects.Bullet'
local Player = {}
Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)
    self.ship = Ship.new({
        position = { x = 400, y = 500 },
        speed = 700,
        spritePath = 'Assets/Ship (7) (1).png',
        spriteWidth = 383,
        spriteHeight = 331,
        tailPath = 'Assets/BlueTail__000.png',
        tailWidth = 115,
        tailHeight = 33,
        animationFrames = 2,
        frameTime = 0.08
    })
    self.bullets = Bullet.new({
        speed = 1000,
        spritePath = 'Assets/OrangeSpin__000.png'
    })
    return self
end

function Player:draw()
    self.ship:draw()
    -- Draw bullets if needed
end

function Player:switchShip(shipConfig)
    self.ship = Ship.new(shipConfig)
end
function Player:fireBullets()
    -- Approximate X and Y offsets from the center to each cannon
    local cannonOffsetX = 20 -- Horizontal distance from center to cannons
    local cannonOffsetY = 70 -- Vertical distance from center to cannons
    self.bullets:fire(cannonOffsetX, cannonOffsetY, self.ship.angle - math.pi / 2, self.ship.position.x, self.ship.position.y, 2)
end
function Player:drawBullets()
    self.bullets:draw()
end
function Player:updateBullets(dt)
    self.bullets:updateBullets(dt)    
end


function Player:move(dt)
    -- Define movement speed and acceleration
    local maxSpeed = self.ship.speed*dt
    local acceleration = 15 -- Adjust acceleration as needed
    local friction = 6

    -- Check for input and adjust movement vector
    if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
        self.ship.xspeed = self.ship.xspeed - acceleration * dt
        self.ship.thrust = true
    end
    if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
        self.ship.xspeed = self.ship.xspeed + acceleration * dt
        self.ship.thrust = true
    end
    if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
        self.ship.yspeed = self.ship.yspeed - acceleration * dt
        self.ship.thrust = true
    end
    if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
        self.ship.yspeed = self.ship.yspeed + acceleration * dt
        self.ship.thrust = true
    end

    -- No thrust, apply friction to slow down
    if not (love.keyboard.isDown('left') or love.keyboard.isDown('a') or
            love.keyboard.isDown('right') or love.keyboard.isDown('d') or
            love.keyboard.isDown('up') or love.keyboard.isDown('w') or
            love.keyboard.isDown('down') or love.keyboard.isDown('s')) then
        self.ship.thrust = false
    end

    if not self.ship.thrust then
        -- Apply friction to slow down the ship
        if self.ship.xspeed ~= 0 then
            self.ship.xspeed = self.ship.xspeed - self.ship.xspeed * friction * dt
        end
        if self.ship.yspeed ~= 0 then
            self.ship.yspeed = self.ship.yspeed - self.ship.yspeed * friction * dt
        end

        -- Tail effect scaling
        if self.ship.tail.spriteScale.y > 0.3 then
            self.ship.tail.spriteScale.y = self.ship.tail.spriteScale.y - 1 * dt
        end
    else
        if self.ship.tail.spriteScale.y < 0.8 then
            self.ship.tail.spriteScale.y = self.ship.tail.spriteScale.y + 0.8 * dt
        end
    end

    -- Limit diagonal speed to prevent faster movement
    local length = math.sqrt(self.ship.xspeed * self.ship.xspeed + self.ship.yspeed * self.ship.yspeed)
    if length > maxSpeed then
        self.ship.xspeed = self.ship.xspeed * (maxSpeed / length)
        self.ship.yspeed = self.ship.yspeed * (maxSpeed / length)
    end
    
    -- Apply movement to the ship
    self.ship.position.x = self.ship.position.x  + self.ship.xspeed
    self.ship.position.y = self.ship.position.y + self.ship.yspeed

    -- make sure the ship can't go off screen on x axis
    if self.ship.position.x + self.ship.hitbox.radius < self.ship.hitbox.radius*2 then
        self.ship.position.x = self.ship.position.x  - self.ship.xspeed
    elseif self.ship.position.x + self.ship.hitbox.radius > love.graphics.getWidth() then
        self.ship.position.x = self.ship.position.x  - self.ship.xspeed
    end

    -- make sure the ship can't go off screen on y axis
    if self.ship.position.y + self.ship.hitbox.radius < self.ship.hitbox.radius*2 then
        self.ship.position.y = self.ship.position.y - self.ship.yspeed
    elseif self.ship.position.y + self.ship.hitbox.radius > love.graphics.getHeight() then
        self.ship.position.y = self.ship.position.y - self.ship.yspeed
    end


    -- Get mouse position
    local mouse_x, mouse_y = love.mouse.getPosition()

    -- Calculate the desired angle based on mouse position
    local targetAngle = math.atan2(mouse_y - self.ship.position.y, mouse_x - self.ship.position.x) + math.pi / 2

    -- Get the angular difference
    local angleDifference = targetAngle - self.ship.angle

    -- Normalize the angle difference to keep it between -π and π
    angleDifference = (angleDifference + math.pi) % (2 * math.pi) - math.pi

    -- Limit the angular speed
    local maxRotationSpeed = math.pi * dt * 2-- adjust this value
    if math.abs(angleDifference) > maxRotationSpeed then
        angleDifference = maxRotationSpeed * (angleDifference < 0 and -1 or 1)
    end

    -- Apply the limited angle change
    self.ship.angle = self.ship.angle + angleDifference


end

return Player