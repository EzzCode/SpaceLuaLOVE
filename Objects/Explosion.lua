-- Objects/Explosion.lua
local Explosion = {}
Explosion.__index = Explosion

function Explosion.new()
    local self = setmetatable({}, Explosion)
    self.x = 0
    self.y = 0
    self.sprite = {
        image = love.graphics.newImage('Assets/spritesheet.png'),
        height = 359,
        width = 4334,
        quad_width = 394,
        quad_height = 359,
    }
    self.animation = {
        frames = 11,
        current_frame = 1,
        time = 0.08,
        current_time = 0,
        playing = false
    }
    self.quads = self:createQuads()
    return self
end

function Explosion:createQuads()
    local quads = {}
    for i = 1, self.animation.frames do
        quads[i] = love.graphics.newQuad(
            self.sprite.quad_width * (i - 1),
            0,
            self.sprite.quad_width,
            self.sprite.quad_height,
            self.sprite.width,
            self.sprite.height
        )
    end
    return quads
end

function Explosion:update(dt)
    if self.animation.playing then
        self.animation.current_time = self.animation.current_time + dt
        if self.animation.current_time >= self.animation.time then
            self.animation.current_frame = self.animation.current_frame + 1
            self.animation.current_time = 0
        end
        if self.animation.current_frame > self.animation.frames then
            self.animation.current_frame = 1
            self.animation.playing = false
        end
    end
end

function Explosion:draw()
    if self.animation.playing then
        love.graphics.draw(
            self.sprite.image,
            self.quads[self.animation.current_frame],
            self.x,
            self.y,
            0,
            0.6, 0.6,
            self.sprite.quad_width / 2,
            self.sprite.quad_height / 2
        )
    end
end

function Explosion:play(x, y)
    self.x = x
    self.y = y
    self.animation.playing = true
end

return Explosion