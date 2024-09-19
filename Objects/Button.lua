-- Define the Button class
local Button = {}
Button.__index = Button  -- Set Button as the metatable for its instances

-- Button constructor
function Button:new(text, func, funcArgs, width, height)
    -- Create a new table for each button instance
    local instance = setmetatable({}, Button)
    
    -- Initialize properties
    instance.text = text or "Button"
    instance.func = func or function() end
    instance.funcArgs = funcArgs or {}
    instance.width = width or 100
    instance.height = height or 50
    instance.x = 0
    instance.y = 0
    instance.textOffsetX = 0
    instance.textOffsetY = 0

    return instance
end

-- Method to check if the button was pressed
function Button:checkPressed(mouseX, mouseY)
    if mouseX > self.x and mouseX < self.x + self.width and mouseY > self.y and mouseY < self.y + self.height then
        if self.funcArgs then
            self.func(self.funcArgs)
        else
            self.func()
        end
    end
end

-- Method to draw the button on the screen
function Button:draw(x, y, textOffsetX, textOffsetY)
    -- Update button position
    self.x = x or self.x
    self.y = y or self.y

    -- Calculate text position relative to the button
    self.textOffsetX = textOffsetX or (self.width / 2 - love.graphics.getFont():getWidth(self.text) / 2)
    self.textOffsetY = textOffsetY or (self.height / 2 - love.graphics.getFont():getHeight() / 2)

    -- Draw the button rectangle
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw the button text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.text, self.x + self.textOffsetX, self.y + self.textOffsetY)
end

return Button
