-- Objects/Button.lua
local Button = {}
Button.__index = Button

function Button:new(text, func, funcArgs, width, height)
    local self = setmetatable({}, Button)
    
    self.text = text or "Button"
    self.func = func or function() end
    self.funcArgs = funcArgs
    self.width = width or 140
    self.height = height or 45
    self.x = 0
    self.y = 0
    self.cornerRadius = 12
    self.colors = {
        normal = {
            top = {0.2, 0.6, 0.8},
            bottom = {0.1, 0.4, 0.6}
        },
        hover = {
            top = {0.3, 0.7, 0.9},
            bottom = {0.2, 0.5, 0.7}
        },
        pressed = {
            top = {0.1, 0.4, 0.6},
            bottom = {0.05, 0.3, 0.5}
        },
        text = {1, 1, 1},
        outline = {1, 1, 1, 0.5}
    }
    self.isHovered = false
    self.isPressed = false
    self.shadowOffset = 3
    self.scale = 1  -- For scaling effect on hover

    return self
end

function Button:update(mouseX, mouseY)
    self.isHovered = self:isPointInside(mouseX, mouseY)
    self.isPressed = self.isHovered and love.mouse.isDown(1)
    
    -- Scaling effect
    if self.isHovered then
        self.scale = 1.05
    else
        self.scale = 1
    end
end

function Button:checkPressed(mouseX, mouseY)
    if self:isPointInside(mouseX, mouseY) then
        print(self.text .. " was pressed")
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

    love.graphics.push()
    
    -- Apply scaling around the center of the button
    love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2)
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.width / 2, -self.height / 2)
    
    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", self.shadowOffset, self.shadowOffset, self.width, self.height, self.cornerRadius, self.cornerRadius)

    -- Determine current color scheme
    local colorScheme = self.isPressed and self.colors.pressed or (self.isHovered and self.colors.hover or self.colors.normal)
    
    -- Draw button gradient
    self:drawGradient(0, 0, self.width, self.height, colorScheme.top, colorScheme.bottom)

    -- Draw button outline
    love.graphics.setColor(self.colors.outline)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0, self.width, self.height, self.cornerRadius, self.cornerRadius)

    -- Draw text shadow
    love.graphics.setColor(0, 0, 0, 0.5)  -- Shadow color
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local textX = (self.width - textWidth) / 2
    local textY = (self.height - textHeight) / 2
    love.graphics.print(self.text, textX + 2, textY + 2)

    -- Draw main text
    love.graphics.setColor(self.colors.text)
    love.graphics.print(self.text, textX, textY)
    
    love.graphics.pop()
end

function Button:drawGradient(x, y, width, height, colorTop, colorBottom)
    -- Simulate a gradient by drawing two rectangles
    love.graphics.setColor(colorBottom)
    love.graphics.rectangle("fill", x, y, width, height, self.cornerRadius, self.cornerRadius)
    
    love.graphics.setColor(colorTop)
    love.graphics.rectangle("fill", x, y + height / 4, width, height / 1.25, self.cornerRadius, self.cornerRadius)
end

return Button