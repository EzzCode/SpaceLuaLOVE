local Ship = require('Objects.Ship')
local Bullet = require('Objects.Bullet')
local Sprite = require('Components.Sprite')
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
    self.explosionDelay = 0.5
    self.explosionTimer = 0
    self.warningDuration = 4
    self.warningScrollX = 0

    self:initShip()
    self:initCannons()
    self:initBullets()
    self:initExplosions()
    self:initLaser()
end

function Enemy:initShip()
    self.ship = Ship.new({
        position = { x = love.graphics.getWidth() - 100, y = love.graphics.getHeight() / 2 },
        speed = 20,
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
    self.ship.position.x = love.graphics.getWidth() -
        (self.ship.shipSprite.sprite.height * self.ship.shipSprite.sprite.spriteScale.x / 2) - 20
    self:setupHitboxes()
end

function Enemy:setupHitboxes()
    self.ship.hitboxes = {
        {
            x = self.ship.position.x - self.ship.shipSprite.sprite.height / 2 * self.ship.shipSprite.sprite.spriteScale
                .x,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 4 * self.ship.shipSprite.sprite.spriteScale.y,
            width = 440,
            height = 110
        },
        {
            x = self.ship.position.x - self.ship.shipSprite.sprite.height / 2 * self.ship.shipSprite.sprite.spriteScale
                .x,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 4 * self.ship.shipSprite.sprite.spriteScale.y +
                155,
            width = 440,
            height = 110
        },
        {
            x = self.ship.position.x - 25,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y +
                100,
            width = 220,
            height = 355
        },
        {
            x = self.ship.position.x + self.ship.shipSprite.sprite.height / 4 * self.ship.shipSprite.sprite.spriteScale
                .x - 25,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y +
                50,
            width = 50,
            height = 455
        },
        {
            x = self.ship.position.x + self.ship.shipSprite.sprite.height / 4 * self.ship.shipSprite.sprite.spriteScale
                .x +
                25,
            y = self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y,
            width = 55,
            height = 555
        },
        {
            x = self.ship.position.x - self.ship.shipSprite.sprite.height / 4 * self.ship.shipSprite.sprite.spriteScale
                .x,
            y = self.ship.position.y - 25,
            width = 225,
            height = 40
        }
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

    for i = 1, 2 do
        local sign = (i == 1) and 1 or -1
        table.insert(self.cannons.list, {
            x = self.ship.position.x - 100,
            y = self.ship.position.y + sign * 82,
            angle = -math.pi / 2,
        })
    end
end

function Enemy:initBullets()
    self.bullets = {
        type1 = Bullet.new({
            speed = 1000,
            spritePath = 'Assets/BlueSpin__000.png'
        }),
        type2 = Bullet.new({
            speed = 500,
            spritePath = 'Assets/BlueBlast__001.png',
            scale = 0.6
        })
    }
end

function Enemy:initExplosions()
    self.explosions = {
        ship = Sprite.new(
            {
                spritePath = 'Assets/spritesheet.png',
                animationFrames = 11,
                frameTime = 0.08,
                spriteScale = { x = 1.5, y = 1.5 },
                playOnce = true
            }
        ),
        cannons = {}
    }
    for i = 1, #self.cannons.list do
        local sprite = Sprite.new(
            {
                spritePath = 'Assets/spritesheet.png',
                animationFrames = 11,
                frameTime = 0.08,
                spriteScale = { x = 0.6, y = 0.6 },
                playOnce = true
            }
        )
        table.insert(self.explosions.cannons, sprite)
    end
end

function Enemy:initLaser()
    self.laser = {
        list = {},
        spawnWarning = false,                 -- Indicates if the warning should be shown
        warningTimer = self.warningDuration, -- Set the warning timer
    }
    local OffsetX, OffsetY = -1000, 152
    for i = 1, 2 do
        local sign = (i == 1) and 1 or -1
        table.insert(self.laser.list, Sprite.new(
            {
                x = self.ship.position.x + OffsetX,
                y = self.ship.position.y + sign * OffsetY,
                spritePath = 'Assets/3.png',
                spriteScale = { x = 1, y = 2 },
                animationFrames = 8,
                frameTime = 0.1,
                playOnce = true
            }
        ))
    end
    self.laser.list[1].sprite.spriteScale.x = -(love.graphics.getWidth() / self.laser.list[1].sprite.width) + 4
    self.laser.list[2].sprite.spriteScale.x = self.laser.list[1].sprite.spriteScale.x
end

function Enemy:drawWarning(x, y, width, height)
    -- Draw the red rectangle for warning
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle('line', x - width / 2, y - height / 4, width, height / 3, 10, 10)
    love.graphics.setLineWidth(1)

    -- Text setup
    local warningText = "---Danger---     "
    local textWidth = love.graphics.getFont():getWidth(warningText)
    self.warningScrollX = self.warningScrollX % textWidth

    -- Calculate start position for scrolling text
    local startX = x - width / 2 - self.warningScrollX

    -- Draw infinitely scrolling text from right to left
    love.graphics.setColor(1, 0, 0, 1)

    -- Draw the text multiple times to ensure wrapping
    for i = -1, math.floor(width / textWidth) do
        love.graphics.printf(warningText, startX + i * textWidth, y - height / 5, textWidth, "left")
    end

    -- Reset to default color
    love.graphics.setColor(1, 1, 1, 1)
end

function Enemy:updateLasers(dt)
    for _, laser in ipairs(self.laser.list) do
        if self.laser.spawnWarning then
            self.laser.warningTimer = self.laser.warningTimer - dt
            
            -- Update the warning scroll position (move right)
            self.warningScrollX = (self.warningScrollX + 50 * dt)
            
            if self.laser.warningTimer <= 0 then
                self.laser.spawnWarning = false
                self.laser.warningTimer = self.warningDuration
            end
        else
            laser:updateAnimation(dt)
        end
    end
end

function Enemy:drawLasers()
    for _, laser in ipairs(self.laser.list) do
        if self.laser.spawnWarning then
            self:drawWarning(laser.x, laser.y, -(laser.sprite.width * laser.sprite.spriteScale.x), laser.sprite.height)
        else
            laser:draw()
        end
    end
end
function Enemy:fireLasers()
    local OffsetX, OffsetY = -30, 152
    self.laser.spawnWarning = true
    for i, laser in ipairs(self.laser.list) do
        local sign = (i == 1) and 1 or -1
        laser.x = (self.ship.position.x + OffsetX) + (laser.sprite.width * laser.sprite.spriteScale.x) / 2
        laser.y = self.ship.position.y + OffsetY * sign
        laser.animation.currentFrame = 1
        laser.animation.isPlaying = true
        laser.animation.playOnce = true
    end
end

function Enemy:draw()
    self.ship:draw()
    self:drawCannons()
    self:drawHealthBar()
    self:drawExplosions()
    self:drawBullets()
    self:drawLasers()
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
    love.graphics.rectangle('fill', love.graphics.getWidth() - 27,
        self.ship.position.y - self.ship.shipSprite.sprite.width / 2 * self.ship.shipSprite.sprite.spriteScale.y, 10,
        self.life / 100 * 555)
    love.graphics.setColor(1, 1, 1, a)
    love.graphics.print('Health', love.graphics.getWidth(),
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
        local maxRotationSpeed = 0.4 * dt
        cannon.angle = cannon.angle + math.min(math.max(angleDifference, -maxRotationSpeed), maxRotationSpeed)
    end
end

function Enemy:updateFiringMechanism(dt)
    self.timeSinceLastBurst = self.timeSinceLastBurst + dt
    local fireChance = love.math.random(1, 450)

    if fireChance <= 2 then
        self:fireBullets("type2")
    end
    if fireChance == 1 and not self.laser.spawnWarning then
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
        type1 = { offsetX = 15, offsetY = 100, angle = -math.pi / 2, count = 2 },
        type2 = { offsetX = 20, offsetY = 150, angle = -math.pi, count = 1 }
    }
    local config = bulletConfig[type]
    for _, cannon in ipairs(self.cannons.list) do
        local sign = (type == "type1") and 1 or 0
        self.bullets[type]:fire(config.offsetX, config.offsetY, cannon.angle * sign + config.angle, cannon.x, cannon.y,
            config.count)
    end
end

function Enemy:triggerExplosions()
    self.isExploding = true
    self.explosionQueue = {}
    for i, cannon in ipairs(self.cannons.list) do
        table.insert(self.explosionQueue, { type = "cannon", index = i, x = cannon.x, y = cannon.y })
    end
    table.insert(self.explosionQueue, { type = "ship", x = self.ship.position.x + 100, y = self.ship.position.y - 50 })
end

function Enemy:updateExplosions(dt)
    if not self.isExploding then return end

    self.explosionTimer = self.explosionTimer + dt
    if self.explosionTimer >= self.explosionDelay and #self.explosionQueue > 0 then
        local nextExplosion = table.remove(self.explosionQueue, 1)
        if nextExplosion.type == "cannon" then
            self.explosions.cannons[nextExplosion.index].x = nextExplosion.x
            self.explosions.cannons[nextExplosion.index].y = nextExplosion.y
            self.explosions.cannons[nextExplosion.index].animation.currentFrame = 1
            self.explosions.cannons[nextExplosion.index].animation.isPlaying = true
        elseif nextExplosion.type == "ship" then
            self.explosions.ship.x = nextExplosion.x
            self.explosions.ship.y = nextExplosion.y
            self.explosions.ship.animation.isPlaying = true
        end
        self.explosionTimer = 0
        return
    end

    for _, explosion in ipairs(self.explosions.cannons) do
        explosion:updateAnimation(dt)
    end
    self.explosions.ship:updateAnimation(dt)
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
