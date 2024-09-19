local Player = require 'Objects.Player'
local Ship = require 'Objects.Ship'

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new()
    local self = setmetatable({}, Enemy)
    self.player = Player:new()
    self.player:switchShip({
        position = { x = screenWidth, y = screenHeight / 2 },
        speed = 700,
        angle = -math.pi/2,
        spritePath = 'Assets/Ship (18)-1.png',
        spriteScale = { x = 0.5, y = 0.5 },
        tailPath = 'Assets/BlueTail__000.png',
        tailScale = { x = 0, y = 0 },
        tailWidth = 115,
        tailHeight = 33,
        animationFrames = 1,
        frameTime = 0.08
    })
    self.player.ship.position.x = screenWidth - (self.player.ship.sprite.height * self.player.ship.sprite.spriteScale.x / 2) - 20
    self.cannons = {
        sprite = {
            image = love.graphics.newImage('Assets/Orange (46).png'),
            spriteScale = { x = 0.6, y = 0.6 },
            height = 104,
            width = 202,
            angle = 0,
        },
    }

    return self
end
function Enemy:draw()
    self.player:draw()
    local OffsetX = 80 -- Horizontal distance from center to cannons
    local OffsetY = 85 -- Vertical distance from center to cannons
    for i = 1, 2 do
        local sign = (i == 1) and 1 or -1 -- 1 for the right cannon, -1 for the left cannon
        local X = self.player.ship.position.x + math.cos(self.player.ship.angle  - math.pi / 2) * OffsetY -  sign * math.sin(self.player.ship.angle  - math.pi / 2) * OffsetX
        local Y = self.player.ship.position.y + math.sin(self.player.ship.angle  - math.pi / 2) * OffsetY +  sign * math.cos(self.player.ship.angle  - math.pi / 2) * OffsetX
        love.graphics.draw(self.cannons.sprite.image, X, Y, self.cannons.sprite.angle*sign, 0.5, 0.5, self.cannons.sprite.height / 2, self.cannons.sprite.width / 2 + 50)
    end

end
return Enemy