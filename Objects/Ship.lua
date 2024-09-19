local Ship = {}
Ship.__index = Ship

function Ship.new(config)
    local self = setmetatable({}, Ship)
    self.position = config.position or { x = 400, y = 500 }
    self.speed = config.speed or 500
    self.angle = config.angle or 0
    self.sprite = {
        image = love.graphics.newImage(config.spritePath),
        width = config.spriteWidth,
        height = config.spriteHeight,
        spriteScale = config.spriteScale or {x = 0.3, y = 0.4}
    }
    self.hitbox = {
        x = self.position.x,
        y = self.position.y,
        radius = (self.sprite.width / 2) * self.sprite.spriteScale.x
    }
    self.thrust = false
    self.xspeed = 0
    self.yspeed = 0
    self.tail = {
        image = love.graphics.newImage(config.tailPath),
        width = config.tailWidth,
        height = config.tailHeight,
        spriteScale = config.tailScale or {x = 0.6, y = 0.4}
    }
    self.animation = {
        frames = config.animationFrames or 2,
        currentFrame = 1,
        frameTime = config.frameTime or 0.08,
        elapsedTime = 0,
        isPlaying = false
    }
    self.quads = {}

    -- Create quads for ship animation frames
    local spriteSheetWidth = self.sprite.width * self.animation.frames
    for i = 1, self.animation.frames do
        self.quads[i] = love.graphics.newQuad(
            (i - 1) * self.sprite.width, 
            0, 
            self.sprite.width, 
            self.sprite.height, 
            spriteSheetWidth, 
            self.sprite.height
        )
    end

    return self
end

function Ship:draw()
    -- debug  
    -- the hitbox of the ship
    if false then        
        local debugOffsetX = 0
        local debugOffsetY = 10
        self.hitbox.x = self.position.x -  math.sin(self.angle  - math.pi / 2) * debugOffsetX + math.cos(self.angle  - math.pi / 2) * debugOffsetY
        self.hitbox.y = self.position.y +  math.cos(self.angle  - math.pi / 2) * debugOffsetX  + math.sin(self.angle  - math.pi / 2) * debugOffsetY
        love.graphics.circle("line", self.hitbox.x,self.hitbox.y, self.hitbox.radius) 
    end
    -- Draw the ship
    love.graphics.draw(
        self.sprite.image,
        self.quads[self.animation.currentFrame], 
        self.position.x, 
        self.position.y, 
        self.angle, 
        self.sprite.spriteScale.x, self.sprite.spriteScale.y,
        self.sprite.width / 2, 
        self.sprite.height / 2
    )
    local OffsetX = 25 -- Horizontal distance from center to cannons
    local OffsetY = -43 -- Vertical distance from center to cannons
    local X = self.position.x + math.cos(self.angle  - math.pi / 2) * OffsetY -  math.sin(self.angle  - math.pi / 2) * OffsetX
    local Y = self.position.y + math.sin(self.angle  - math.pi / 2) * OffsetY +  math.cos(self.angle  - math.pi / 2) * OffsetX
    -- Draw the tail if thrust is active
    if self.thrust or self.tail.spriteScale.y > 0.3 then
        love.graphics.draw(
            self.tail.image, 
            X, 
            Y, 
            self.angle, 
            self.tail.spriteScale.x, self.tail.spriteScale.y, 
            self.tail.width / 2, 
            self.tail.height / 2
        )
    end
end

return Ship