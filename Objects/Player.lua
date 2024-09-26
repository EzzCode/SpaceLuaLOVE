-- Objects/Player.lua
local Ship = require('Objects.Ship')
local Bullet = require('Objects.Bullet')
local Sprite = require('Components.Sprite')

local Player = {}
Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)
    self.ship = Ship.new({
        position = { x = 400, y = 500 },
        speed = 500 * GlobalScale.x,
        spritePath = 'Assets/Ship (7) (1)greenS.png',
        spriteWidth = 383,
        spriteHeight = 331,
        tailPath = 'Assets/GreenSTail__000.png',
        tailWidth = 115,
        tailHeight = 33,
        animationFrames = 2,
        frameTime = 0.08,
        isPlaying = true,
        spriteScale = { x = 0.3, y = 0.3 },
    })
    self.bullets = Bullet.new({
        speed = 1000,
        spritePath = 'Assets/GreenSSpin__000.png',
        effectPath = 'Assets/GreenBulletExplo.png',
    })
    self.explosion = Sprite.new({
        spritePath = 'Assets/spritesheet.png',
        animationFrames = 11,
        frameTime = 0.08,
        spriteScale = { x = 0.6, y = 0.6 },
        playOnce = true
    })
    self.hitFlag = false
    self.BlinkTimer = 0
    self.BlinkDuration = 3
    return self
end

function Player:initShip()
    self.ship = Ship.new({
        position = { x = 400, y = 500 },
        speed = 1000 * GlobalScale.x,
        spritePath = 'Assets/Ship (7) (1)greenS.png',
        spriteWidth = 383,
        spriteHeight = 331,
        tailPath = 'Assets/GreenSTail__000.png',
        tailWidth = 115,
        tailHeight = 33,
        animationFrames = 2,
        frameTime = 0.08,
        isPlaying = true,
        spriteScale = { x = 0.3, y = 0.3 },
    })
    self.ship:setupHitboxes()
end

function Player:update(dt)
    self:move(dt)
    self.bullets:updateBullets(dt)
    self.explosion:updateAnimation(dt)
end

function Player:draw()
    -- Check if the player is hit and should be blinking
    if not self.explosion.animation.isPlaying then
        if self.hitFlag then
            -- Update the alpha based on the BlinkTimer (alternating between 0 and 1)
            local alpha = math.abs(math.sin(self.BlinkTimer * 10)) -- Adjust 10 to change blink speed

            -- Set the shader and pass the alpha value
            Shader:send("WhiteFactor", alpha)
            love.graphics.setShader(Shader)

            -- Draw the ship with the shader applied (blinking effect)
            self.ship:draw()

            -- Reset shader to avoid affecting other elements
            love.graphics.setShader()
        else
            -- Draw normally when not hit
            self.ship:draw()
        end
    end

    -- Draw bullets normally
    self.bullets:draw()
end

function Player:switchShip(shipConfig)
    self.ship = Ship.new(shipConfig)
end

function Player:fireBullets()
    if self.hitFlag then return end
    local cannonOffsetX = 20 * GlobalScale.x
    local cannonOffsetY = 70 * GlobalScale.y
    self.bullets:fire(cannonOffsetX, cannonOffsetY, self.ship.angle - math.pi / 2,
        self.ship.position.x, self.ship.position.y, 2)
end

function Player:move(dt)
    local friction = 6 * GlobalScale.x
    local acceleration = 30 * GlobalScale.x
    if not self.explosion.animation.isPlaying then

        if love.keyboard.isDown('left', 'a') then
            self.ship.xspeed = self.ship.xspeed - acceleration * dt
            self.ship.thrust = true
        end
        if love.keyboard.isDown('right', 'd') then
            self.ship.xspeed = self.ship.xspeed + acceleration * dt
            self.ship.thrust = true
        end
        if love.keyboard.isDown('up', 'w') then
            self.ship.yspeed = self.ship.yspeed - acceleration * dt
            self.ship.thrust = true
        end
        if love.keyboard.isDown('down', 's') then
            self.ship.yspeed = self.ship.yspeed + acceleration * dt
            self.ship.thrust = true
        end

        if not (love.keyboard.isDown('left', 'a', 'right', 'd', 'up', 'w', 'down', 's')) then
            self.ship.thrust = false
        end
    else
        self.ship.thrust = false
    end
    if self.hitFlag then
        if not self.explosion.animation.isPlaying then 
            self.BlinkTimer = self.BlinkTimer + dt
        end
        if self.BlinkTimer >= self.BlinkDuration then
            self.BlinkTimer = 0
            self.hitFlag = false
        end
    end
    self.ship:applyFriction(dt, friction)
    self.ship:limitSpeed(dt)
    self.ship:updatePosition()
    self.ship:constrainToScreen()
    self.ship:updateAngle(dt)
    self.ship:update(dt)
end

function Player:destroyShip()
    TriggerExplosions(self.explosion, self.ship.position.x, self.ship.position.y, 0.6)
end

return Player
