-- Objects/Player.lua
local Ship = require('Objects.Ship')
local Bullet = require('Objects.Bullet')

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
        spritePath = 'Assets/GreenSSpin__000.png'
    })
    return self
end
function Player:initShip()
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
    self.ship:setupHitboxes()
end
function Player:update(dt)
    self:move(dt)
    self.bullets:updateBullets(dt)
end

function Player:draw()
    self.ship:draw()
    self.bullets:draw()
end

function Player:switchShip(shipConfig)
    self.ship = Ship.new(shipConfig)
end

function Player:fireBullets()
    local cannonOffsetX = 20 * GlobalScale.x
    local cannonOffsetY = 70 * GlobalScale.y
    self.bullets:fire(cannonOffsetX, cannonOffsetY, self.ship.angle - math.pi / 2, 
        self.ship.position.x, self.ship.position.y, 2)
end

function Player:move(dt)
    local acceleration = 15 * GlobalScale.x
    local friction = 6 * GlobalScale.x

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

    self.ship:applyFriction(dt, friction)
    self.ship:limitSpeed(dt)
    self.ship:updatePosition()
    self.ship:constrainToScreen()
    self.ship:updateAngle(dt)
end


return Player