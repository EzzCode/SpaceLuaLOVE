local Background = require 'Objects.Background'

function Game()
    local game = {
        lives = 3,
        enemies = {},
        state = {
            menu = true,
            paused = false,
            running = false,
            over = false
        },
        background = Background.new({
            {image = "Assets/Space Background (1).png", speed = 50},  -- Farther, slower
            {image = "Assets/Space Background (2).png", speed = 75}, -- Middle layer
            {image = "Assets/Space Background (3).png", speed = 100}  -- Closer, faster
        }),

        changeGameState = function(self, state)
            for k in pairs(self.state) do
                self.state[k] = (k == state)
            end
        end,

        startGame = function(self, Player, Enemy)
            self:changeGameState("running")
            Enemy:init()
            self.lives = 3
            Player:initShip()
            Player.ship.position.x = 10 + Player.ship.hitboxes[1].radius
            Player.ship.position.y = WindowHeight / 2
            self.enemies = {}
        end,

        update = function(self, dt)
            if self.state.running then
                self.background:update(dt, 1, 0, false)
            elseif self.state.menu then
                self.background:update(dt, 0.5, 0.2 , false)
            elseif self.state.paused then
                self.background:update(dt, 1, 1, true)
            end
        end,

        draw = function(self)
            self.background:draw()
        end,

        fullscreenToggle = function()
            love.window.setFullscreen(not love.window.getFullscreen())
            CalculateGlobals ()
        end
    }

    return game
end

return Game