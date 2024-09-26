local Sprite = {}
Sprite.__index = Sprite
--[[
    config = {
        x = 0,
        y = 0,
        angle = 0,
        speed = 500,
        spritePath = 'Assets/spritesheet.png',
        animationFrames = 11,
        frameTime = 0.08
        isPlaying = false,
        playOnce = true,
    }
]]

function Sprite.new(config)
    local self = setmetatable({}, Sprite)
    self.x = config.x or 0
    self.y = config.y or 0
    self.angle = config.angle or 0
    self.speed = config.speed or 500
    self.sprite = self:setupSprite(config)
    self.animation = self:setupAnimation(config)
    return self
end

function Sprite:setupSprite(config)
    local image = love.graphics.newImage(config.spritePath)
    local  spriteScale = config.spriteScale or { x = 1, y = 1}
    spriteScale.x = spriteScale.x * GlobalScale.x
    spriteScale.y = spriteScale.y * GlobalScale.y
    return {
        image = image,
        width = config.spriteWidth or image:getWidth(),
        height = config.spriteHeight or image:getHeight(),
        spriteScale = spriteScale
    }
end

function Sprite:setupAnimation(config)
    local animation = {
        frames = config.animationFrames or 1,
        currentFrame = 1,
        frameTime = config.frameTime or 0.08,
        elapsedTime = 0,
        isPlaying = false or config.isPlaying,
        playOnce = false or config.playOnce,
        quads = {}
    }

    local spriteSheetWidth = self.sprite.image:getWidth()
    self.sprite.width = config.quadWidth or spriteSheetWidth / animation.frames
    self.sprite.height = config.quadHeight or self.sprite.image:getHeight()
    for i = 1, animation.frames do
        animation.quads[i] = love.graphics.newQuad(
            (i - 1) * self.sprite.width,
            0,
            self.sprite.width,
            self.sprite.height,
            spriteSheetWidth,
            self.sprite.height
        )
    end

    return animation
end

function Sprite:updateAnimation(dt)
    if self.animation.isPlaying == false then return end
    self.animation.elapsedTime = self.animation.elapsedTime + dt
    if self.animation.elapsedTime > self.animation.frameTime then
        self.animation.elapsedTime = self.animation.elapsedTime - self.animation.frameTime
        self.animation.currentFrame = self.animation.currentFrame + 1
        if self.animation.currentFrame > self.animation.frames then
            self.animation.currentFrame = 1
            if self.animation.playOnce then
                self.animation.isPlaying = false
            end
        end
    end
end

function Sprite:draw()
    if self.animation.isPlaying then
        love.graphics.draw(
            self.sprite.image,
            self.animation.quads[self.animation.currentFrame],
            self.x,
            self.y,
            self.angle,
            self.sprite.spriteScale.x , self.sprite.spriteScale.y ,
            self.sprite.width / 2,
            self.sprite.height / 2
        )
    end
end
return Sprite