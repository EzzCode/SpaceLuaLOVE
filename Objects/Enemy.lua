local Player = require 'Objects.Player'
local Ship = require 'Objects.Ship'
local Bullet = require 'Objects.Bullet'

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new()
    local self = setmetatable({}, Enemy)
    self.player = Player:new()
    -- Initialize enemy properties
    self.fireDelay = 3                 -- Time in seconds between bursts
    self.bulletBurstCount = 5          -- Number of bullets in a burst
    self.bulletInterval = 0.1          -- Interval in seconds between bullets in a burst
    self.timeSinceLastBurst = 0        -- Timer to track time between bursts
    self.burstBulletTimer = 0          -- Timer to track time between bullets in a burst
    self.bulletsFiredInBurst = 0 -- Counter for bullets fired in the current burst
    self.inBurst = false               -- Flag to know if we're in the middle of a burst


    self.player:switchShip({
        position = { x = screenWidth, y = screenHeight / 2 },
        speed = 700,
        angle = -math.pi / 2,
        spritePath = 'Assets/Ship (18)-1.png',
        spriteScale = { x = 0.5, y = 0.5 },
        tailPath = 'Assets/BlueTail__000.png',
        tailScale = { x = 0, y = 0 },
        tailWidth = 115,
        tailHeight = 33,
        animationFrames = 1,
        frameTime = 0.08
    })
    self.player.ship.position.x = screenWidth -
        (self.player.ship.sprite.height * self.player.ship.sprite.spriteScale.x / 2) - 20
    self.cannons = {
        list = {},
        sprite = {
            image = love.graphics.newImage('Assets/Orange (46).png'),
            spriteScale = { x = 0.6, y = 0.6 },
            height = 104,
            width = 202,
            angle = 0,
        },

    }
    self.bullets = {
        type1 = Bullet.new({
            speed = 1500,
            spritePath = 'Assets/BlueSpin__000.png'
        })
    }

    local OffsetX = 80                    -- Horizontal distance from center to cannons
    local OffsetY = 85                    -- Vertical distance from center to cannons
    for i = 1, 2 do
        local sign = (i == 1) and 1 or -1 -- 1 for the right cannon, -1 for the left cannon
        local X = self.player.ship.position.x + math.cos(self.player.ship.angle - math.pi / 2) * OffsetY -
            sign * math.sin(self.player.ship.angle - math.pi / 2) * OffsetX
        local Y = self.player.ship.position.y + math.sin(self.player.ship.angle - math.pi / 2) * OffsetY +
            sign * math.cos(self.player.ship.angle - math.pi / 2) * OffsetX
        love.graphics.draw(self.cannons.sprite.image, X, Y, self.cannons.sprite.angle * sign,
            self.cannons.sprite.spriteScale.x, self.cannons.sprite.spriteScale.y,
            self.cannons.sprite.height / 2, self.cannons.sprite.width / 2 + 50)

        local Cannon = {
            x = X, -- Cannon position
            y = Y,
            angle = -math.pi / 2,
        }
        table.insert(self.cannons.list, Cannon)
    end

    return self
end

function Enemy:moveCannons(player, dt)
    for i = 1, #self.cannons.list do
        local cannon = self.cannons.list[i]
        local targetx, targety = player.ship.position.x, player.ship.position.y

        -- Calculate the desired angle based on mouse position
        local targetAngle = math.atan2(targety - cannon.y, targetx - cannon.x) + math.pi / 2

        -- Get the angular difference
        local angleDifference = targetAngle - cannon.angle

        -- Normalize the angle difference to keep it between -π and π
        angleDifference = (angleDifference + math.pi) % (2 * math.pi) - math.pi

        -- Limit the angular speed
        local maxRotationSpeed = 0.2 * dt -- adjust this value
        if math.abs(angleDifference) > maxRotationSpeed then
            angleDifference = maxRotationSpeed * (angleDifference < 0 and -1 or 1)
        end

        -- Apply the limited angle change
        cannon.angle = cannon.angle + angleDifference
    end
end

function Enemy:draw()
    self.player:draw()

    for i = 1, #self.cannons.list do
        local cannon = self.cannons.list[i]

        love.graphics.draw(self.cannons.sprite.image, cannon.x, cannon.y, cannon.angle,
            self.cannons.sprite.spriteScale.x, self.cannons.sprite.spriteScale.y,
            self.cannons.sprite.height / 2, self.cannons.sprite.width / 2 + 50)
    end
end

function Enemy:fireBullets()
    for i = 1, #self.cannons.list do
        -- Approximate X and Y offsets from the center to each cannon
        local cannonOffsetX = 15  -- Horizontal distance from center to cannons
        local cannonOffsetY = 100 -- Vertical distance from center to cannons
        local cannon = self.cannons.list[i]
        self.bullets.type1:fire(cannonOffsetX, cannonOffsetY, cannon.angle - math.pi / 2, cannon.x, cannon.y, 2)
    end
end

function Enemy:update(dt)
    self.bullets.type1:updateBullets(dt)

    -- Timer for starting a new burst
    self.timeSinceLastBurst = self.timeSinceLastBurst + dt

    -- If not in a burst and the timer exceeds the fire delay, start a burst
    if not self.inBurst and self.timeSinceLastBurst >= self.fireDelay then
        self.inBurst = true
        self.timeSinceLastBurst = 0        -- Reset the burst timer
        self.bullets.type1FiredInBurst = 0 -- Reset the bullet counter for the burst
    end

    -- If we're in a burst, manage the firing of individual bullets
    if self.inBurst then
        self.burstBulletTimer = self.burstBulletTimer + dt

        -- Fire a bullet if enough time has passed
        if self.burstBulletTimer >= self.bulletInterval then
            self.burstBulletTimer = 0 -- Reset interval timer
            self.bullets.type1FiredInBurst = self.bullets.type1FiredInBurst + 1

            self:fireBullets()

            -- If we've fired the full burst, stop the burst
            if self.bullets.type1FiredInBurst >= self.bulletBurstCount then
                self.inBurst = false -- End the burst
            end
        end
    end
end

function Enemy:drawBullets()
    self.bullets.type1:draw()
end

return Enemy
