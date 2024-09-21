-- Objects/Bullet.lua
local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(config)
    local self = setmetatable({}, Bullet)
    self.speed = config.speed or 1000
    self.sprite = {
        image = love.graphics.newImage(config.spritePath),
    }
    self.list = {}
    return self
end

function Bullet:draw()
    for _, bullet in ipairs(self.list) do
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
        
        table.insert(self.list, {
            x = cannonX,
            y = cannonY,
            angle = angle,
        })
    end
end

function Bullet:collision(hitboxes)
    local hits = 0
    for i = #self.list, 1, -1 do
        local bullet = self.list[i]
        for _, hitbox in ipairs(hitboxes) do
            if self:checkCollision(bullet, hitbox) then
                table.remove(self.list, i)
                hits = hits + 1
                break
            end
        end
    end
    return hits
end

function Bullet:checkCollision(bullet, hitbox)
    if hitbox.radius then
        local dx = hitbox.x - bullet.x
        local dy = hitbox.y - bullet.y
        return math.sqrt(dx^2 + dy^2) < hitbox.radius
    elseif hitbox.width and hitbox.height then
        return bullet.x >= hitbox.x and bullet.x <= hitbox.x + hitbox.width and
               bullet.y >= hitbox.y and bullet.y <= hitbox.y + hitbox.height
    end
    return false
end

return Bullet
