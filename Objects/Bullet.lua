local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(config)
    local self = setmetatable({}, Bullet)
    self.x = config.x or 0
    self.y = config.y or 0
    self.angle = config.angle or 0
    self.speed = config.speed or 1000
    self.sprite = {
        image = love.graphics.newImage(config.spritePath),
    }
    self.list = {}
    return self
    
end

function Bullet:draw()
    for i = 1, #self.list do
        local bullet = self.list[i]
        love.graphics.draw(
            self.sprite.image,
            bullet.x,
            bullet.y,
            bullet.angle,
            0.4, 0.4,
            self.sprite.image:getWidth() / 2,
            self.sprite.image:getHeight() / 2
        )
    end
end

function Bullet:updateBullets(dt)
    for i = #self.list, 1, -1 do
        local bullet = self.list[i]

        -- Move bullet in the direction of the ship's angle
        bullet.x = bullet.x + math.cos(bullet.angle) * self.speed * dt
        bullet.y = bullet.y + math.sin(bullet.angle) * self.speed * dt

        -- Remove bullets that go off-screen
        if bullet.x < 0 or bullet.x > love.graphics.getWidth() or bullet.y < 0 or bullet.y > love.graphics.getHeight() then
            table.remove(self.list, i)
        end
    end
end

function Bullet:fire(OffsetX, OffsetY, angle,x ,y, number)
        -- Approximate X and Y offsets from the center to each canno
        -- Create two bullets, one for each cannon
        for i = 1, number do
            local sign = (i == 1) and 1 or -1 -- 1 for the right cannon, -1 for the left cannon
    
            -- Calculate the cannon's position relative to the ship
            local cannonX = x + math.cos(angle) * OffsetY -
                sign * math.sin(angle) * OffsetX
            local cannonY = y + math.sin(angle) * OffsetY +
                sign * math.cos(angle) * OffsetX
    
            -- Create the bullet with its starting position and angle
            local bullet = {
                x = cannonX,                             -- Cannon position
                y = cannonY,
                angle = angle, -- Bullet follows the ship's angle
            }
    
            -- Insert the bullet into the bullets table
            table.insert(self.list, bullet)
    end
end

return Bullet