local Background = require 'Objects.Background'
local Menu = require 'States.Menu'


local Game = {}
Game.__index = Game

-- Constructor
function Game:new(player, enemy, asteroid)
    local self = setmetatable({}, Game)
    self.sfx = Sfx
    self.player = player
    self.enemy = enemy
    self.asteroid = asteroid
    self.lives = 5
    self.enemies = {}
    self.state = {
        menu = true,
        paused = false,
        running = false,
        over = false,
        win = false
    }
    self.background = Background.new({
        { image = "Assets/Space Background (1).png", speed = 50 }, -- Farther, slower
        { image = "Assets/Space Background (2).png", speed = 75 }, -- Middle layer
        { image = "Assets/Space Background (3).png", speed = 100 } -- Closer, faster
    })
    self.menu = self:initMenu(player, enemy)
    self.lifeIcon = love.graphics.newImage('Assets/Ship (7).png')

    return self
end

function Game:initMenu(player, enemy)
    return Menu.new(self, player, enemy)
end

-- Method to change the game state
function Game:changeGameState(state)
    local r, g, b = love.graphics.getColor()
    for k in pairs(self.state) do
        self.state[k] = (k == state)
    end
    if state == "running" then
        self.sfx.bgm:setVolume(0.3)
    elseif state == "over" then
        self.sfx:playFX("lose", "single")
        self.sfx.fxPlayed = false
    end
    if state == "paused" then
        love.graphics.setColor(r, g, b, 0.5)
        self.sfx:stopBGM()
        Opacity = 0.5
    else
        love.graphics.setColor(r, g, b, 1)
        self.sfx:playBGM()
        self.sfx.bgm:setVolume(0.6)
        Opacity = 1
    end
end

-- Method to start the game
function Game:startGame()
    Sfx:playFX("click", "single")
    self:changeGameState("running")
    self.enemy:init()
    self.asteroid.list = {}
    self.player.bullets.list = {}
    self.player.hitFlag = false
    self.player.BlinkTimer = 0
    self.lives = 5
    self.player:initShip()
    self.player.ship.position.x = 10 + self.player.ship.hitboxes[1].radius
    self.player.ship.position.y = WindowHeight / 2
    self.enemies = {}
    Sfx.fxPlayed = false
end

-- Method to update game state
function Game:update(dt)
    if self.state.running then
        self.background:update(dt, 1, 0, false)
    elseif self.state.menu then
        self.background:update(dt, 0.5, 0.2, false)
    elseif self.state.paused then
        self.background:update(dt, 1, 1, true)
    end
end

-- Method to draw game objects
function Game:draw()
    if self.state.running then
        self.background:draw()
        if self.lives > 0 then
            self.player:draw()
        end
        self.asteroid:draw()
        self.enemy:draw()
        local image = self.lifeIcon
        local iconScale = 0.1 * GlobalScale.x  -- Scale down the life icon
        local iconWidth = image:getWidth() * iconScale
        local iconHeight = image:getHeight() * iconScale
        local spacing = iconWidth + 10  -- Spacing between icons
    
        for i = 1, self.lives do
            love.graphics.draw(self.lifeIcon, 10 + (i - 1) * spacing, 30, 0, iconScale, iconScale)
        end
    elseif self.state.menu then
        local r, g, b = love.graphics.getColor()
        love.graphics.setColor(r, g, b, 0.5)
        self.background:draw()
        love.graphics.setColor(r, g, b, 1)
        love.graphics.setFont(love.graphics.newFont(55))
        love.graphics.printf("Ezz can't think of a title", 0, WindowHeight / 4, WindowWidth, "center")
        love.graphics.setFont(love.graphics.newFont(12))
        self.menu:draw("main")
    elseif self.state.paused then
        local r, g, b = love.graphics.getColor()
        love.graphics.setColor(r, g, b, 0.5)
        self.background:draw()
        self.player:draw()
        self.enemy:draw()
        self.asteroid:draw()
        love.graphics.setColor(r, g, b, 1)
        local image = self.lifeIcon
        local iconScale = 0.1 * GlobalScale.x  -- Scale down the life icon
        local iconWidth = image:getWidth() * iconScale
        local iconHeight = image:getHeight() * iconScale
        local spacing = iconWidth + 10  -- Spacing between icons
    
        for i = 1, self.lives do
            love.graphics.draw(self.lifeIcon, 10 + (i - 1) * spacing, 30, 0, iconScale, iconScale)
        end
        love.graphics.setFont(love.graphics.newFont(30))
        love.graphics.printf('Paused', 0, WindowHeight / 2 - 50, WindowWidth, 'center')
        love.graphics.setFont(love.graphics.newFont(15))
        love.graphics.printf('Press ESC to resume', 0, WindowHeight / 2 + 50, WindowWidth, 'center')
        love.graphics.setFont(love.graphics.newFont(12))
    elseif self.state.over then
        self.menu:draw("over")
        local a = math.abs(math.cos(love.timer.getTime()  % 2 * math.pi))
        love.graphics.setFont(love.graphics.newFont(60))
        love.graphics.setColor(1, 0.2, 0.2, a)
        love.graphics.printf('Skill Issue!', 0, WindowHeight / 4 , WindowWidth, 'center')
        love.graphics.setColor(1, 1, 1, Opacity)
        love.graphics.setFont(love.graphics.newFont(12))
    elseif self.state.win then
        love.graphics.setColor(1, 1, 1, 0.75)
        self.player.bullets.list = {}
        self.background:draw()
        self.player:draw()
        self.enemy:draw()
        self.menu:draw("win")
        love.graphics.setFont(love.graphics.newFont(60))
        local a = math.abs(math.cos(love.timer.getTime() * 2 % 2 * math.pi))
        love.graphics.setColor(1, 1, 1, a)
        love.graphics.printf('You Win!', 0, WindowHeight / 4 , WindowWidth, 'center')
        love.graphics.setColor(1, 1, 1, Opacity)
        love.graphics.setFont(love.graphics.newFont(12))
    end
    love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 10)
end

-- Method to toggle fullscreen mode
function Game:fullscreenToggle()
    love.window.setFullscreen(not love.window.getFullscreen())
    CalculateGlobals()
end

return Game
