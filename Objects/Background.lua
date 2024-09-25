local Background = {}
Background.__index = Background

-- Create a new Background with multiple layers
function Background.new(layers)
    local self = setmetatable({}, Background)
    self.layers = {}

    -- Initialize each layer with its own image, speed, and scale factor
    for i, layer in ipairs(layers) do
        local layerData = {
            image = love.graphics.newImage(layer.image),
            speed = layer.speed,
            scaleFactor = 1,
            x = 0,
            y = 0,
            width = love.graphics.newImage(layer.image):getWidth(),
            height = love.graphics.newImage(layer.image):getHeight(),
        }
        -- Scale the background based on screen size
        layerData.scaleFactor = WindowHeight / layerData.height
        table.insert(self.layers, layerData)
    end
    self:updateScaleFactor()
    
    return self
end

-- Update background position for each layer based on direction and speed
function Background:update(dt, directionX, directionY, isPaused)
    if not isPaused then
        for _, layer in ipairs(self.layers) do
            -- Update horizontal and vertical positions based on speed and direction
            layer.x = (layer.x + directionX * layer.speed * dt) % (layer.width * layer.scaleFactor)
            layer.y = (layer.y + directionY * layer.speed * dt) % (layer.height * layer.scaleFactor)
        end
    end
end

-- Draw each layer of the background, repeating it to fill the screen
function Background:draw()
    for _, layer in ipairs(self.layers) do
        local tilesX = math.ceil(WindowWidth / (layer.width * layer.scaleFactor)) + 1
        local tilesY = math.ceil(WindowHeight / (layer.height * layer.scaleFactor)) + 1
        for x = 0, tilesX - 1 do
            for y = 0, tilesY - 1 do
                love.graphics.draw(
                    layer.image,
                    x * layer.width * layer.scaleFactor - layer.x,
                    y * layer.height * layer.scaleFactor - layer.y,
                    0,
                    layer.scaleFactor,
                    layer.scaleFactor
                )
            end
        end
    end
end

-- Dynamically change the scroll speed for all layers
function Background:setScrollSpeed(speed)
    for _, layer in ipairs(self.layers) do
        layer.speed = speed
    end
end

-- Update scale factor based on screen height
function Background:updateScaleFactor()
    for _, layer in ipairs(self.layers) do
        layer.scaleFactor = WindowHeight / layer.height
    end
end

-- Pause or resume scrolling
function Background:togglePause(pauseState)
    self.isPaused = pauseState
end

return Background