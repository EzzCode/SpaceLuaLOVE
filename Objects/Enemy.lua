-- Objects/Enemy.lua
local Player = require('Objects.Player')
local Ship = require('Objects.Ship')
local Bullet = require('Objects.Bullet')
local Explosion = require('Objects.Explosion')

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new()
    local self = setmetatable({}, Enemy)
    self:init()
    return self
end

function Enemy:init()
    self.life = 100
    self.fireDelay = 3
    self.bulletBurstCount = 5
    self.bulletInterval = 0.1
    self.timeSinceLastBurst = 0
    self.burstBulletTimer = 0
    self.bulletsFiredInBurst = 0
    self.inBurst = false
    self.isExploding = false
    self.explosionQueue = {}
    self.explosionDelay = 0.5 -- Delay between explosions
    self.explosionTimer = 0


    self:initShip()
    self:initCannons()
    self:initBullets()
    self:initExplosions()
end

function Enemy:initShip()
    self.player = Player.new()
    self.player:switchShip({
        position = { x = love.graphics.getWidth(), y = love.graphics.getHeight() / 2 },
        speed = 20,
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
    self.player.ship.position.x = love.graphics.getWidth() -
        (self.player.ship.sprite.height * self.player.ship.sprite.spriteScale.x / 2) - 20

    self.player.ship.hitboxes = {
        {
            x = self.player.ship.position.x - self.player.ship.sprite.height / 2 * self.player.ship.sprite.spriteScale.x,
            y = self.player.ship.position.y - self.player.ship.sprite.width / 4 * self.player.ship.sprite.spriteScale.y,
            width = 450,
            height =110
        },
        {
            x = self.player.ship.position.x - self.player.ship.sprite.height / 2 * self.player.ship.sprite.spriteScale.x,
            y = self.player.ship.position.y - self.player.ship.sprite.width / 4 * self.player.ship.sprite.spriteScale.y + 155,
            width = 450,
            height = 110
        },
        {
            x = self.player.ship.position.x,
            y = self.player.ship.position.y - self.player.ship.sprite.width / 2 * self.player.ship.sprite.spriteScale.y + 100,
            width = 220,
            height = 355
        },
        {
            x = self.player.ship.position.x + self.player.ship.sprite.height / 4 * self.player.ship.sprite.spriteScale.x,
            y = self.player.ship.position.y - self.player.ship.sprite.width / 2 * self.player.ship.sprite.spriteScale.y,
            width = 110,
            height = 555
        },
        {
            x = self.player.ship.position.x - self.player.ship.sprite.height / 4 * self.player.ship.sprite.spriteScale.x,
            y = self.player.ship.position.y - 25,
            width = 225,
            height = 40
        },
        -- {
        --     x = self.player.ship.position.x + self.player.ship.sprite.height / 4 * self.player.ship.sprite.spriteScale.x,
        --     y = self.player.ship.position.y + self.player.ship.sprite.width / 2 * self.player.ship.sprite.spriteScale.y - 100,
        --     width = 110,
        --     height = 100
        -- }
    }
end

function Enemy:initCannons()
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

    local OffsetX = 80
    local OffsetY = 85
    for i = 1, 2 do
        local sign = (i == 1) and 1 or -1
        local X = self.player.ship.position.x + math.cos(self.player.ship.angle - math.pi / 2) * OffsetY -
            sign * math.sin(self.player.ship.angle - math.pi / 2) * OffsetX
        local Y = self.player.ship.position.y + math.sin(self.player.ship.angle - math.pi / 2) * OffsetY +
            sign * math.cos(self.player.ship.angle - math.pi / 2) * OffsetX

        table.insert(self.cannons.list, {
            x = X,
            y = Y,
            angle = -math.pi / 2,
        })
    end
end

function Enemy:initBullets()
    self.bullets = {
        type1 = Bullet.new({
            speed = 1500,
            spritePath = 'Assets/BlueSpin__000.png'
        })
    }
end

function Enemy:initExplosions()
    self.explosions = {
        ship = Explosion.new(),
        cannons = {}
    }

    for i = 1, #self.cannons.list do
        table.insert(self.explosions.cannons, Explosion.new())
    end
end

function Enemy:draw()
    self.player:draw()
    self:drawCannons()
    self:drawHealthBar()
    self:drawExplosions()
    self:drawBullets()
end

function Enemy:drawExplosions()
    for _, explosion in ipairs(self.explosions.cannons) do
        explosion:draw()
    end
    self.explosions.ship:draw()
end

function Enemy:drawCannons()
    for _, cannon in ipairs(self.cannons.list) do
        love.graphics.draw(self.cannons.sprite.image, cannon.x, cannon.y, cannon.angle,
            self.cannons.sprite.spriteScale.x, self.cannons.sprite.spriteScale.y,
            self.cannons.sprite.height / 2, self.cannons.sprite.width / 2 + 50)
    end
end

function Enemy:drawHealthBar()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1, 0, 0, a)
    love.graphics.rectangle('fill', 0, love.graphics.getHeight() - 25, self.life / 100 * love.graphics.getWidth(), 25)
    love.graphics.setColor(r, g, b, a)
    love.graphics.print('Health: ' .. self.life, 10, love.graphics.getHeight() - 20)
end

function Enemy:triggerExplosions()
    self.isExploding = true
    self.explosionQueue = {}

    -- Queue cannon explosions
    for i, cannon in ipairs(self.cannons.list) do
        table.insert(self.explosionQueue, {
            type = "cannon",
            index = i,
            x = cannon.x,
            y = cannon.y
        })
    end

    -- Queue ship explosion last
    table.insert(self.explosionQueue, {
        type = "ship",
        x = self.player.ship.position.x + 100,
        y = self.player.ship.position.y
    })
end

function Enemy:moveCannons(player, dt)
    for i, cannon in ipairs(self.cannons.list) do
        local targetx, targety = player.ship.position.x, player.ship.position.y
        local targetAngle = math.atan2(targety - cannon.y, targetx - cannon.x) + math.pi / 2
        local angleDifference = (targetAngle - cannon.angle + math.pi) % (2 * math.pi) - math.pi
        local maxRotationSpeed = 0.2 * dt

        if math.abs(angleDifference) > maxRotationSpeed then
            angleDifference = maxRotationSpeed * (angleDifference < 0 and -1 or 1)
        end

        cannon.angle = cannon.angle + angleDifference
    end
end

function Enemy:fireBullets()
    for _, cannon in ipairs(self.cannons.list) do
        local cannonOffsetX = 15
        local cannonOffsetY = 100
        self.bullets.type1:fire(cannonOffsetX, cannonOffsetY, cannon.angle - math.pi / 2, cannon.x, cannon.y, 2)
    end
end

function Enemy:update(dt, player)
    self.bullets.type1:updateBullets(dt)

    if self.life > 0 and not self.isExploding then
        self:moveCannons(player, dt)
        self:updateFiringMechanism(dt)
    elseif self.life <= 0 and not self.isExploding then
        self:triggerExplosions()
    end

    self:updateExplosions(dt)
end

function Enemy:updateExplosions(dt)
    if not self.isExploding then return end

    self.explosionTimer = self.explosionTimer + dt

    if self.explosionTimer >= self.explosionDelay and #self.explosionQueue > 0 then
        local nextExplosion = table.remove(self.explosionQueue, 1)

        if nextExplosion.type == "cannon" then
            self.explosions.cannons[nextExplosion.index]:play(nextExplosion.x, nextExplosion.y)
        elseif nextExplosion.type == "ship" then
            self.explosions.ship:play(nextExplosion.x, nextExplosion.y)
        end

        self.explosionTimer = 0
    end

    for _, explosion in ipairs(self.explosions.cannons) do
        explosion:update(dt)
    end
    self.explosions.ship:update(dt)
end

function Enemy:updateFiringMechanism(dt)
    self.timeSinceLastBurst = self.timeSinceLastBurst + dt

    if not self.inBurst and self.timeSinceLastBurst >= self.fireDelay then
        self.inBurst = true
        self.timeSinceLastBurst = 0
        self.bulletsFiredInBurst = 0
    end

    if self.inBurst then
        self.burstBulletTimer = self.burstBulletTimer + dt

        if self.burstBulletTimer >= self.bulletInterval then
            self.burstBulletTimer = 0
            self.bulletsFiredInBurst = self.bulletsFiredInBurst + 1
            self:fireBullets()

            if self.bulletsFiredInBurst >= self.bulletBurstCount then
                self.inBurst = false
            end
        end
    end
end

function Enemy:drawBullets()
    self.bullets.type1:draw()
end

function Enemy:move(dt)
    if not self.isExploding then
        -- Determine movement speed
        local speed = self.player.ship.speed * dt
        local direction = self.direction or 1 -- Default direction to 1 (right)

        -- Move the ship
        self.player.ship.position.y = self.player.ship.position.y + direction * speed
        for _, hitbox in ipairs(self.player.ship.hitboxes) do
            hitbox.y = hitbox.y + direction * speed
        end
        for _, cannon in ipairs(self.cannons.list) do
            cannon.y = cannon.y + direction * speed
        end

        -- Constrain to screen and check if constrained
        if self.player.ship:constrainToScreen() then
            -- Flip direction if constrained
            self.direction = -direction
            self.player.ship.position.y = self.player.ship.position.y +
            self.direction * speed                                                         -- Move back slightly to avoid sticking
            for _, hitbox in ipairs(self.player.ship.hitboxes) do
                hitbox.y = hitbox.y + self.direction * speed
            end
        else
            self.direction = direction -- Update direction if not constrained
        end
    end
end

return Enemy
