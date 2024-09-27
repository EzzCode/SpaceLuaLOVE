local Button = {}
Button.__index = Button

function Button:new(text, func, funcArgs, width, height)
    local self = setmetatable({}, Button)
    
    self.text = text or "Button"
    self.func = func or function() end
    self.funcArgs = funcArgs
    self.width = width or 100
    self.height = height or 50
    self.x = 0
    self.y = 0

    return self
end

function Button:checkPressed(mouseX, mouseY)
    if self:isPointInside(mouseX, mouseY) then
        if self.funcArgs then
            self.func(self.funcArgs)
        else
            self.func()
        end
    end
        
end

function Button:isPointInside(x, y)
    return x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
end

function Button:draw(x, y)
    self.x = x or self.x
    self.y = y or self.y

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2
    love.graphics.print(self.text, textX, textY)
end

return Button