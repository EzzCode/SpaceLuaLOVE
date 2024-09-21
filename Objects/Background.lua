local Background = {}
Background.__index = Background

function Background.new()
    local self = setmetatable({}, Background)
    self.x = 0
    self.y = 0
    self.speed = 100
    self.image = love.graphics.newImage("Assets/Space Background1.png")
    self.width = 3000
    self.height = 1000
    self.scrollSpeed = 100
    self.scaleFactor = 1
    return self
end

function Background:update(dt)
    self.x = (self.x + self.scrollSpeed * dt) % self.width
end

function Background:draw()
    local tilesX = math.ceil(love.graphics.getWidth() / (self.width * self.scaleFactor)) + 1
    local tilesY = math.ceil(love.graphics.getHeight() / (self.height * self.scaleFactor)) + 1

    for x = 0, tilesX - 1 do
        for y = 0, tilesY - 1 do
            love.graphics.draw(self.image,
                x * self.width * self.scaleFactor - self.x,
                y * self.height * self.scaleFactor - self.y, 0,
                self.scaleFactor, self.scaleFactor)
        end
    end
end

function Background:updateScaleFactor()
    local screenHeight = love.graphics.getHeight()
    self.scaleFactor = screenHeight < self.height and screenHeight / self.height or 1
end

return Background