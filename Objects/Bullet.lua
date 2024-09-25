-- Objects/Bullet.lua
local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(config)
    local self = setmetatable({}, Bullet)
    self.speed = config.speed or 1000
    self.sprite = {
        image = love.graphics.newImage(config.spritePath),
        scale = config.scale or 0.4
    }
    self.list = {}
    return self
end

function Bullet:draw()
    for _, bullet in ipairs(self.list) do
        love.graphics.draw(
            self.sprite.image,
            bullet.x, bullet.y,
            bullet.angle,
            self.sprite.scale, self.sprite.scale,
            self.sprite.image:getWidth() / 2,
            self.sprite.image:getHeight() / 2
        )

        -- Debug hitbox
        if Debugging then
            love.graphics.setColor(1, 0, 0)
            love.graphics.ellipse("line", bullet.x, bullet.y, bullet.radiusX, bullet.radiusY)
            love.graphics.setColor(1, 1, 1)  -- Reset color
        end
    end
end

function Bullet:updateBullets(dt)
    for i = #self.list, 1, -1 do
        local bullet = self.list[i]
        bullet.x = bullet.x + math.cos(bullet.angle) * self.speed * dt
        bullet.y = bullet.y + math.sin(bullet.angle) * self.speed * dt
        
        if self:isOffScreen(bullet) then
            table.remove(self.list, i)
        end
    end
end

function Bullet:isOffScreen(bullet)
    return bullet.x < 0 or bullet.x > love.graphics.getWidth() or 
           bullet.y < 0 or bullet.y > love.graphics.getHeight()
end

function Bullet:fire(OffsetX, OffsetY, angle, x, y, number)
    for i = 1, number do
        local sign = (i == 1) and 1 or -1
        local cannonX = x + math.cos(angle) * OffsetY - sign * math.sin(angle) * OffsetX
        local cannonY = y + math.sin(angle) * OffsetY + sign * math.cos(angle) * OffsetX

        -- Bullet's elliptical hitbox
        local bullet = {
            x = cannonX,
            y = cannonY,
            angle = angle,
            radiusX = self.sprite.image:getWidth() * self.sprite.scale / 3 + 5,  -- Major axis
            radiusY = self.sprite.image:getHeight() * self.sprite.scale / 3 - 5  -- Minor axis
        }

        table.insert(self.list, bullet)
    end
end
function Bullet:collision(objects)
    local hits = 0
    for i = #self.list, 1, -1 do
        local bullet = self.list[i]
        for j = #objects, 1, -1 do
            local obj = objects[j]

            if obj.isAlive ~= nil then  -- It's an asteroid
                if self:checkCollision(bullet, obj) then
                    table.remove(self.list, i)  -- Remove bullet
                    obj.isAlive = false         -- Mark asteroid as dead
                    hits = hits + 1
                    break  -- Stop checking more objects for this bullet
                end
            else  -- It's a general hitbox
                if self:checkCollision(bullet, obj) then
                    table.remove(self.list, i)  -- Remove bullet
                    hits = hits + 1
                    break  -- Stop checking more objects for this bullet
                end
            end
        end
    end
    return hits
end


function Bullet:checkCollision(bullet, hitbox)
    if hitbox.radius then  -- Circle hitbox
        -- Step 1: Calculate distance between bullet and hitbox centers
        local dx, dy = bullet.x - hitbox.x, bullet.y - hitbox.y
        local distance = math.sqrt(dx * dx + dy * dy)

        -- Step 2: Find the angle of the line connecting the centers
        local angle = math.atan2(dy, dx) - bullet.angle

        -- Step 3: Calculate the radius of the ellipse in the direction of the circle's center
        local radiusAtAngle = (bullet.radiusX * bullet.radiusY) /
            math.sqrt((bullet.radiusY * math.cos(angle))^2 + (bullet.radiusX * math.sin(angle))^2)

        -- Step 4: Check if the distance is less than the sum of the circle's radius and the ellipse's radius at that angle
        return distance < (hitbox.radius + radiusAtAngle)

    elseif hitbox.width and hitbox.height then  -- Rectangle hitbox
        -- Find the closest point on the rectangle to the ellipse center
        local closestX = math.max(hitbox.x, math.min(bullet.x, hitbox.x + hitbox.width))
        local closestY = math.max(hitbox.y, math.min(bullet.y, hitbox.y + hitbox.height))
        
        -- Calculate the vector from the ellipse center to the closest point
        local dx, dy = closestX - bullet.x, closestY - bullet.y
        
        -- Rotate the vector by the negative of the ellipse's angle
        local rotatedDx = dx * math.cos(-bullet.angle) - dy * math.sin(-bullet.angle)
        local rotatedDy = dx * math.sin(-bullet.angle) + dy * math.cos(-bullet.angle)
        
        -- Check if the rotated point is inside the ellipse
        return (rotatedDx * rotatedDx) / (bullet.radiusX * bullet.radiusX) + 
               (rotatedDy * rotatedDy) / (bullet.radiusY * bullet.radiusY) <= 1
    end

    return false  -- No collision detected
end

return Bullet