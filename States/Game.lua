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
        background = Background.new(),

        changeGameState = function(self, state)
            for k in pairs(self.state) do
                self.state[k] = (k == state)
            end
        end,

        startGame = function(self, Player)
            self:changeGameState("running")
            self.lives = 3
            Player.ship.position.x = 0 + Player.ship.hitboxes[1].radius
            Player.ship.position.y = love.graphics.getHeight() / 2
            self.enemies = {}
        end,

        update = function(self, dt)
            if self.state.running then
                self.background:update(dt)
            end
        end,

        draw = function(self)
            self.background:draw()
        end
    }

    return game
end

return Game