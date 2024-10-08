local Sprite = require 'Components.Sprite'

local Ship = {}
Ship.__index = Ship
--[[
    Ship.new
    Creates a new Ship object
    config: A table containing the ship's configuration
    config {
        position: A table containing the ship's position { x, y }
        speed: The ship's speed
        angle: The ship's angle
        spritePath: The path to the ship's sprite
        spriteWidth: The width of the ship's sprite
        spriteHeight: The height of the ship's sprite
        spriteScale: The scale of the ship's sprite
        tailPath: The path to the ship's tail sprite
        tailWidth: The width of the ship's tail sprite
        tailHeight: The height of the ship's tail sprite
        tailScale: The scale of the ship's tail sprite
        animationFrames: The number of animation frames
        frameTime: The time between animation frames
    }
    Returns the new Ship objects
]]

function Ship.new(config)
    local self = setmetatable({}, Ship)
    self.position = config.position or { x = 400, y = 500 }
    self.speed = config.speed or 500
    self.angle = config.angle or 0
    self.shipSprite = Sprite.new(config)
    self.hitboxes = self:setupHitboxes()
    self.thrust = false
    self.xspeed = 0
    self.yspeed = 0
    self.tail = self:setupTail(config)
    return self
end



function Ship:setupHitboxes()
    return {
        {x = self.position.x, y = self.position.y, radius = (self.shipSprite.sprite.width / 2) * self.shipSprite.sprite.spriteScale.x}
    }
end

function Ship:setupTail(config)
    local spriteScale = config.tailScale or { x = 0.6, y = 0.4 }
    spriteScale.x = spriteScale.x * GlobalScale.x
    spriteScale.y = spriteScale.y * GlobalScale.y
    return {
        image = love.graphics.newImage(config.tailPath),
        width = config.tailWidth,
        height = config.tailHeight,
        spriteScale = spriteScale
    }
end



function Ship:findHitbox(OffsetX, OffsetY)
    for i, hitbox in ipairs(self.hitboxes) do
        hitbox.x = self.position.x + math.cos(self.angle - math.pi / 2) * OffsetY -
            math.sin(self.angle - math.pi / 2) * OffsetX
        hitbox.y = self.position.y + math.sin(self.angle - math.pi / 2) * OffsetY +
            math.cos(self.angle - math.pi / 2) * OffsetX
    end
end

function Ship:draw()
    self:drawShip()
    self:drawTail()
    if Debugging then
        self:drawHitboxes()
    end
end

function Ship:drawShip()
    self.shipSprite.x = self.position.x
    self.shipSprite.y = self.position.y
    self.shipSprite.angle = self.angle
    self.shipSprite:draw()
end

function Ship:drawTail()
    if self.thrust or self.tail.spriteScale.y > 0.3 then
        local OffsetX = 25 * GlobalScale.x
        local OffsetY = -43 * GlobalScale.y
        local X = self.position.x + math.cos(self.angle - math.pi / 2) * OffsetY -
            math.sin(self.angle - math.pi / 2) * OffsetX
        local Y = self.position.y + math.sin(self.angle - math.pi / 2) * OffsetY +
            math.cos(self.angle - math.pi / 2) * OffsetX
        
        love.graphics.draw(
            self.tail.image,
            X,
            Y,
            self.angle,
            self.tail.spriteScale.x, self.tail.spriteScale.y ,
            self.tail.width / 2,
            self.tail.height / 2
        )
    end
end

function Ship:drawHitboxes()
    for i, hitbox in ipairs(self.hitboxes) do
        if hitbox.radius then
            love.graphics.circle("line", hitbox.x, hitbox.y, hitbox.radius)
        elseif hitbox.width and hitbox.height then
            love.graphics.rectangle("line", hitbox.x, hitbox.y, hitbox.width, hitbox.height)
        end
    end
end

function Ship:applyFriction(dt, friction)
    if not self.thrust then
        self.xspeed = self.xspeed - self.xspeed * friction * dt
        self.yspeed = self.yspeed - self.yspeed * friction * dt
        
        if self.tail.spriteScale.y  > 0.3  then
            self.tail.spriteScale.y = self.tail.spriteScale.y - 1 * dt
        end
    else
        if self.tail.spriteScale.y < 0.8  then
            self.tail.spriteScale.y = self.tail.spriteScale.y + 0.8 * dt 
        end
    end
end

function Ship:limitSpeed(dt)
    local maxSpeed = self.speed * dt
    local length = math.sqrt(self.xspeed * self.xspeed + self.yspeed * self.yspeed)
    if length > maxSpeed then
        self.xspeed = self.xspeed * (maxSpeed / length)
        self.yspeed = self.yspeed * (maxSpeed / length)
    end
end

function Ship:updatePosition()
    self.position.x = self.position.x + self.xspeed
    self.position.y = self.position.y + self.yspeed
end

function Ship:constrainToScreen()
    local screenWidth, screenHeight = WindowWidth, WindowHeight
    local constrained = false

    -- Store old position for checking
    local oldX, oldY = self.position.x, self.position.y

    for _, hitbox in ipairs(self.hitboxes) do
        if hitbox.radius then
            -- Handle circular hitbox
            local radius = hitbox.radius

            -- X-axis constraint
            self.position.x = math.max(radius, math.min(self.position.x, screenWidth - radius))

            -- Y-axis constraint
            self.position.y = math.max(radius, math.min(self.position.y, screenHeight - radius))
        
        elseif hitbox.width and hitbox.height then
            -- Handle rectangular hitbox
            local halfWidth, halfHeight = hitbox.width / 2, hitbox.height / 2

            -- X-axis constraint
            self.position.x = math.max(halfWidth, math.min(self.position.x, screenWidth - halfWidth))

            -- Y-axis constraint
            self.position.y = math.max(halfHeight, math.min(self.position.y, screenHeight - halfHeight))
        end
    end

    -- Check if the position has changed
    constrained = (self.position.x ~= oldX or self.position.y ~= oldY)

    return constrained
end



function Ship:collisions(hitboxes, move)
    local collided = false
    for _, hitbox in ipairs(hitboxes) do
        for _, shipHitbox in ipairs(self.hitboxes) do
            local collision, resolveX, resolveY = false, 0, 0

            if shipHitbox.radius and hitbox.radius then
                -- Circle vs Circle
                local dx, dy = shipHitbox.x - hitbox.x, shipHitbox.y - hitbox.y
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance < shipHitbox.radius + hitbox.radius then
                    collision = true
                    local overlap = shipHitbox.radius + hitbox.radius - distance
                    resolveX, resolveY = (dx / distance) * overlap, (dy / distance) * overlap
                end
            elseif shipHitbox.width and hitbox.width then
                -- Rectangle vs Rectangle (Improved resolution calculation)
                if shipHitbox.x < hitbox.x + hitbox.width and shipHitbox.x + shipHitbox.width > hitbox.x and
                   shipHitbox.y < hitbox.y + hitbox.height and shipHitbox.y + shipHitbox.height > hitbox.y then
                    collision = true
                    local overlapX1 = hitbox.x + hitbox.width - shipHitbox.x
                    local overlapX2 = shipHitbox.x + shipHitbox.width - hitbox.x
                    local overlapY1 = hitbox.y + hitbox.height - shipHitbox.y
                    local overlapY2 = shipHitbox.y + shipHitbox.height - hitbox.y

                    local overlapX = math.min(overlapX1, overlapX2)
                    local overlapY = math.min(overlapY1, overlapY2)

                    -- Resolve on the axis with the smaller overlap
                    if overlapX < overlapY then
                        resolveX = shipHitbox.x < hitbox.x and -overlapX or overlapX
                    else
                        resolveY = shipHitbox.y < hitbox.y and -overlapY or overlapY
                    end
                end
            else
                -- Circle vs Rectangle (Improved edge case handling)
                local circle, rect = shipHitbox.radius and shipHitbox or hitbox, shipHitbox.width and shipHitbox or hitbox
                local closestX = math.max(rect.x, math.min(circle.x, rect.x + rect.width))
                local closestY = math.max(rect.y, math.min(circle.y, rect.y + rect.height))
                local dx, dy = circle.x - closestX, circle.y - closestY
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance < circle.radius then
                    collision = true
                    local overlap = circle.radius - distance
                    if distance > 0 then
                        resolveX, resolveY = (dx / distance) * overlap, (dy / distance) * overlap
                    else
                        -- Handle the case where the circle's center is exactly at the rectangle's edge or corner
                        resolveX, resolveY = circle.radius, 0
                    end
                end
            end

            if collision then
                collided = true
                if move then
                    -- Apply a fraction of the resolution to avoid over-correction
                    local fraction = 0.5
                    self.position.x = self.position.x + resolveX * fraction
                    self.position.y = self.position.y + resolveY * fraction
                end
            end
        end
    end
    return collided
end




function Ship:updateAngle(dt)
    local mouse_x, mouse_y = love.mouse.getPosition()
    local targetAngle = math.atan2(mouse_y - self.position.y, mouse_x - self.position.x) + math.pi / 2
    local angleDifference = (targetAngle - self.angle + math.pi) % (2 * math.pi) - math.pi
    local maxRotationSpeed = math.pi * dt * 2
    
    if math.abs(angleDifference) > maxRotationSpeed then
        angleDifference = maxRotationSpeed * (angleDifference < 0 and -1 or 1)
    end
    
    self.angle = self.angle + angleDifference
end

function Ship:update(dt)
    self.shipSprite:updateAnimation(dt)
end
return Ship