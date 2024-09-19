function Game()
    return {
        lives = 3,
        enemies = {},
        state = {
            menu = true,
            paused = false,
            running = false,
            over = false
        },

        changeGameState = function(self, state)
            self.state["menu"] = state == "menu"
            self.state["paused"] = state == "paused"
            self.state["running"] = state == "running"
            self.state["over"] = state == "over"
        end,

        startGame = function(self, Player)
            self:changeGameState("running")
            self.lives = 3
            Player.ship.position.x = 400
            Player.ship.position.y = love.graphics.getHeight() / 2
            self.enemies = {}
            Player.bullets.list = {}
        end,
    }
end

return Game
