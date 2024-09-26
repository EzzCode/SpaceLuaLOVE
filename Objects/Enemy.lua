local Ship = require('Objects.Ship')
local Bullet = require('Objects.Bullet')
local Sprite = require('Components.Sprite')
local Enemy = {}
local explosion = Sprite.new({
    spritePath = 'Assets/spritesheet.png',
    animationFrames = 11,
    frameTime = 0.08,
    spriteScale = { x = 0.6, y = 0.6 },
    playOnce = true
})
Enemy.__index = Enemy

function Enemy.new()
    local self = setmetatable({}, Enemy)
    self:init()
    return self
end

function Enemy:init()
    self.life = 200
    self.fireDelay = 3
    self.bulletBurstCount = 5
    self.bulletInterval = 0.1
    self.timeSinceLastBurst = 0
    self.burstBulletTimer = 0
    self.bulletsFiredInBurst = 0
    self.inBurst = false
    self.isExploding = false
    self.explosionQueue = {}
    self.explosionDelay = 0.5
    self.explosionTimer = 0
    self.warningDuration = 2
    self.warningScrollX = 0

    self:initShip()
    self:initCannons()
    self:initBullets()
    self:initExplosions()
    self:initLaser()
end

function Enemy:initShip()
    self.ship = Ship.new({
        position = { x = WindowWidth - 100 * GlobalScale.x, y = WindowHeight / 2 },
        speed = 20 * GlobalScale.y,
        angle = -math.pi / 2,
        spritePath = 'Assets/Ship (18)-1 (1).png',
        spriteWidth = 1109,
        spriteScale = { x = 0.5, y = 0.5 },
        tailPath = 'Assets/BlueTail__000.png',
        tailScale = { x = 0, y = 0 },
        tailWidth = 115,
        tailHeight = 33,
        animationFrames = 3,
        frameTime = 0.08,
        isPlaying = true
    })
    self.ship.position.x = WindowWidth -
        (self.ship.shipSprite.sprite.height * self.ship.shipSprite.sprite.spriteScale.x / 2) - 20 * GlobalScale.x
    self:setupHitboxes()
end

function Enemy:setupHitboxes()
    self.ship.hitboxes = {
        {
            x = self.ship.position.x - self.ship.shipSprite.sprite.height / 2 * self.ship.shipSprite.sprite.spriteScale
                .x,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 4 * self.ship.shipSprite.sprite.spriteScale.y,
            width = 440 * GlobalScale.x,
            height = 110 * GlobalScale.y
        },
        {
            x = self.ship.position.x - self.ship.shipSprite.sprite.height / 2 * self.ship.shipSprite.sprite.spriteScale
                .x,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 4 * self.ship.shipSprite.sprite.spriteScale.y +
                155 * GlobalScale.y,
            width = 440 * GlobalScale.x,
            height = 110 * GlobalScale.y
        },
        {
            x = self.ship.position.x - 25 * GlobalScale.x,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y +
                100 * GlobalScale.y,
            width = 220 * GlobalScale.x,
            height = 355 * GlobalScale.y
        },
        {
            x = self.ship.position.x + self.ship.shipSprite.sprite.height / 4 * self.ship.shipSprite.sprite.spriteScale
                .x - 25 * GlobalScale.x,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y +
                50 * GlobalScale.y,
            width = 50 * GlobalScale.x,
            height = 455 * GlobalScale.y
        },
        {
            x = self.ship.position.x + self.ship.shipSprite.sprite.height / 4 * self.ship.shipSprite.sprite.spriteScale
                .x +
                25 * GlobalScale.x,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y,
            width = 55 * GlobalScale.x,
            height = 555 * GlobalScale.y
        },
        {
            x = self.ship.position.x - self.ship.shipSprite.sprite.height / 4 * self.ship.shipSprite.sprite.spriteScale
                .x,
            y = self.ship.position.y - 25 * GlobalScale.y,
            width = 225 * GlobalScale.x,
            height = 40 * GlobalScale.y
        }
    }
end

function Enemy:initCannons()
    self.cannons = {
        list = {},
        sprite = {
            image = love.graphics.newImage('Assets/Orange (46).png'),
            spriteScale = { x = 0.6 * GlobalScale.x, y = 0.6 * GlobalScale.y },
            height = 104,
            width = 202,
            angle = 0,
        },
    }

    for i = 1, 2 do
        local sign = (i == 1) and 1 or -1
        table.insert(self.cannons.list, {
            x = self.ship.position.x - 100 * GlobalScale.x,
            y = self.ship.position.y + sign * 82 * GlobalScale.y,
            angle = -math.pi / 2,
        })
    end
end

function Enemy:initBullets()
    self.bullets = {
        type1 = Bullet.new({
            speed = 1000,
            spritePath = 'Assets/BlueSpin__000.png',
            effectPath = 'Assets/BlueBulletExplo.png',
        }),
        type2 = Bullet.new({
            speed = 500,
            spritePath = 'Assets/BlueBlast__001.png',
            effectPath = 'Assets/BlueBulletExplo.png',
            effectScale = 0.6,
            scale = 0.6 
        })
    }
end

function Enemy:initExplosions()
    self.explosions = {
        ship = explosion,
        cannons = {}
    }
    for i = 1, #self.cannons.list do
        local sprite = explosion
        table.insert(self.explosions.cannons, sprite)
    end
end

function Enemy:initLaser()
    self.laser = {
        sprite = Sprite.new({
        x = 0,
        y = 0,
        spritePath = 'Assets/3.png',
        spriteScale = { x = 1, y = 2 * GlobalScale.y },
        animationFrames = 8,
        frameTime = 0.1,
        playOnce = true
    }),
        spawnWarning = false,
        warningTimer = self.warningDuration,
        hitboxes = {}
    }


    -- Calculate scale for full window width
    local scaleX = (WindowWidth / self.laser.sprite.sprite.width) + 4 * GlobalScale.x
    self.laser.sprite.sprite.spriteScale.x = -scaleX
end

function Enemy:drawWarning(x, y, width, height)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setLineWidth(3 * math.min(GlobalScale.x, GlobalScale.y))
    love.graphics.rectangle('line', x - width / 2, y - height / 4, width, height / 3, 10, 10)
    love.graphics.setLineWidth(1)

    local warningText = "---Danger---     "
    local textWidth = love.graphics.getFont():getWidth(warningText)
    self.warningScrollX = (self.warningScrollX or 0) % textWidth

    local startX = x - width / 2 - self.warningScrollX

    for i = -1, math.floor(width / textWidth) do
        love.graphics.printf(warningText, startX + i * textWidth, y - height / 5, textWidth, "left")
    end

    love.graphics.setColor(1, 1, 1, Opacity)
end

function Enemy:updateLasers(dt)
    if self.laser.spawnWarning then
        self.laser.warningTimer = self.laser.warningTimer - dt
        self.warningScrollX = (self.warningScrollX or 0) + 50 * GlobalScale.x * dt

        if self.laser.warningTimer <= 0 then
            self.laser.spawnWarning = false
            self.laser.warningTimer = self.warningDuration
            self.laser.sprite.animation.isPlaying = true
        end
    else
        self.laser.sprite:updateAnimation(dt)
    end
end

function Enemy:drawLasers()
    self.laser.hitboxes = {}
    local width = - self.laser.sprite.sprite.width * self.laser.sprite.sprite.spriteScale.x
    local height = self.laser.sprite.sprite.height 

    for i = 1, 2 do
        local sign = (i == 1) and 1 or -1
        local OffsetX, OffsetY = -30 * GlobalScale.x, 152 * GlobalScale.y
        self.laser.sprite.x = (self.ship.position.x + OffsetX) + (self.laser.sprite.sprite.width * self.laser.sprite.sprite.spriteScale.x)/2 
        self.laser.sprite.y = self.ship.position.y + OffsetY * sign
        if self.laser.spawnWarning then
            self:drawWarning(self.laser.sprite.x, self.laser.sprite.y, width, height)
        else
            self.laser.sprite:draw()
            if self.laser.sprite.animation.isPlaying then
                table.insert(self.laser.hitboxes, {
                    x = self.laser.sprite.x - width / 2,
                    y = self.laser.sprite.y - height / 4,
                    width =  width,
                    height = height/4
                })
            else
                self.laser.hitboxes = {}
            end
        end
    end

    if Debugging then
        for _, hitbox in ipairs(self.laser.hitboxes) do
            love.graphics.rectangle('line', hitbox.x, hitbox.y, hitbox.width, hitbox.height)
        end
    end
end

function Enemy:fireLasers()
    local OffsetX = -30 * GlobalScale.x
    self.laser.spawnWarning = true
    self.laser.sprite.x = (self.ship.position.x + OffsetX) +
    (self.laser.sprite.sprite.width * self.laser.sprite.sprite.spriteScale.x) / 2
    self.laser.sprite.y = self.ship.position.y
    self.laser.sprite.animation.currentFrame = 1
    self.laser.sprite.animation.elapsedTime = 0
    self.laser.sprite.animation.playOnce = true
    self.laser.sprite.animation.isPlaying = false -- Will be set to true after warning
end

function Enemy:draw()
    self.ship:draw()
    self:drawLasers()
    self:drawCannons()
    self:drawHealthBar()
    self:drawExplosions()
    self:drawBullets()
end

function Enemy:drawCannons()
    for _, cannon in ipairs(self.cannons.list) do
        love.graphics.draw(self.cannons.sprite.image, cannon.x, cannon.y, cannon.angle,
            self.cannons.sprite.spriteScale.x, self.cannons.sprite.spriteScale.y,
            self.cannons.sprite.height / 2, self.cannons.sprite.width / 2 + 50)
    end
end

function Enemy:drawHealthBar()
    if self.life <= 0 then self.life = 0 end
    love.graphics.setColor(1, 0, 0, Opacity)
    love.graphics.rectangle('fill', WindowWidth - 27 * GlobalScale.x,
        self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y,
        10 * GlobalScale.x,
        self.life / 200 * 555 * GlobalScale.y)
    love.graphics.setColor(1, 1, 1, Opacity)
    love.graphics.print('Health', WindowWidth,
        self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y,
        math.pi / 2)
end

function Enemy:drawExplosions()
    for _, explosion in ipairs(self.explosions.cannons) do
        explosion:draw()
    end
    self.explosions.ship:draw()
end

function Enemy:drawBullets()
    self.bullets.type1:draw()
    self.bullets.type2:draw()
end

function Enemy:update(dt, player)
    self.bullets.type1:updateBullets(dt)
    self.bullets.type2:updateBullets(dt)
    self:updateLasers(dt)

    if self.life > 0 and not self.isExploding then
        self:moveCannons(player, dt)
        self:updateFiringMechanism(dt)
        if not Debugging then
            self:move(dt)
        end
    elseif self.life <= 0 and not self.isExploding then
        self:triggerExplosions()
    end
    self:updateExplosions(dt)
end

function Enemy:moveCannons(player, dt)
    for _, cannon in ipairs(self.cannons.list) do
        local targetAngle = math.atan2(player.ship.position.y - cannon.y, player.ship.position.x - cannon.x) +
            math.pi / 2
        local angleDifference = (targetAngle - cannon.angle + math.pi) % (2 * math.pi) - math.pi
        local maxRotationSpeed = 0.3 * dt
        cannon.angle = cannon.angle + math.min(math.max(angleDifference, -maxRotationSpeed), maxRotationSpeed)
    end
end

function Enemy:updateFiringMechanism(dt)
    self.timeSinceLastBurst = self.timeSinceLastBurst + dt
    local fireChance = love.math.random(1, 450)

    if fireChance <= 2 then
        self:fireBullets("type2")
    end
    if fireChance == 1 and not self.laser.sprite.animation.isPlaying then
        self:fireLasers()
    end

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
            self:fireBullets("type1")
            if self.bulletsFiredInBurst >= self.bulletBurstCount then
                self.inBurst = false
            end
        end
    end
end

function Enemy:fireBullets(type)
    local bulletConfig = {
        type1 = { offsetX = 15 * GlobalScale.x, offsetY = 100 * GlobalScale.y, angle = -math.pi / 2, count = 2 },
        type2 = { offsetX = 20 * GlobalScale.x, offsetY = 150 * GlobalScale.y, angle = -math.pi, count = 1 }
    }
    local config = bulletConfig[type]
    for _, cannon in ipairs(self.cannons.list) do
        local sign = (type == "type1") and 1 or 0
        self.bullets[type]:fire(config.offsetX, config.offsetY, cannon.angle * sign + config.angle, cannon.x, cannon.y,
            config.count)
    end
end

function Enemy:triggerExplosions()
    self.bullets.type1.list = {}
    self.bullets.type2.list = {}
    self.laser.list = {}
    self.isExploding = true

    self.explosionQueue = {}
    for i, cannon in ipairs(self.cannons.list) do
        table.insert(self.explosionQueue, { type = "cannon", index = i, x = cannon.x, y = cannon.y })
    end
    table.insert(self.explosionQueue,
        { type = "ship", x = self.ship.position.x + 100 * GlobalScale.x, y = self.ship.position.y - 50 * GlobalScale.y })
end

function Enemy:updateExplosions(dt)
    if not self.isExploding then return end

    self.explosionTimer = self.explosionTimer + dt
    if self.explosionTimer >= self.explosionDelay and #self.explosionQueue > 0 then
        local nextExplosion = table.remove(self.explosionQueue, 1)
        if nextExplosion.type == "cannon" then
            TriggerExplosions(explosion, nextExplosion.x, nextExplosion.y, 0.6)
        elseif nextExplosion.type == "ship" then
            TriggerExplosions(explosion, nextExplosion.x, nextExplosion.y, 1.5)
        end
        self.explosionTimer = 0
        return
    end
    explosion:updateAnimation(dt)
end

function Enemy:move(dt)
    if self.isExploding or self.laser.spawnWarning then return end

    local speed = self.ship.speed * dt
    self.direction = self.direction or 1

    self.ship.position.y = self.ship.position.y + self.direction * speed
    self:updateHitboxes(self.direction * speed)
    self:updateCannons(self.direction * speed)

    if self.ship:constrainToScreen() then
        self.direction = -self.direction
        self.ship.position.y = self.ship.position.y + self.direction * speed
        self:updateHitboxes(self.direction * speed)
        self:updateCannons(self.direction * speed)
    end
end

function Enemy:updateHitboxes(dy)
    for _, hitbox in ipairs(self.ship.hitboxes) do
        hitbox.y = hitbox.y + dy
    end
end

function Enemy:updateCannons(dy)
    for _, cannon in ipairs(self.cannons.list) do
        cannon.y = cannon.y + dy
    end
end

return Enemy
