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
        background = {
            x = 0,
            y = 0,
            speed = 100,
            image = love.graphics.newImage("Assets/Space Background1.png"),
            width = 3000,
            height = 1000,
            scrollSpeed = 100,
            scaleFactor = 1
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
        drawBackground = function(self)
            -- Calculate how many tiles are needed horizontally and vertically
            if self.state["paused"] then
                self.background.scrollSpeed = 0
            else
                self.background.scrollSpeed = 100
            end
            local tilesX = math.ceil(screenWidth / self.background.width) + 1
            local tilesY = math.ceil(screenHeight / self.background.height) + 1

            -- Draw the tiled background with proper scrolling
            for x = 0, tilesX - 1 do
                for y = 0, tilesY - 1 do
                    love.graphics.draw(self.background.image,
                        x * self.background.width * self.background.scaleFactor -
                        self.background.x,
                        y * self.background.height * self.background.scaleFactor - self.background.y, 0,
                        self.background.scaleFactor, self.background.scaleFactor)
                end
            end
        end,
        findScaleFactor = function(self)
            -- Recalculate screen dimensions
            screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
            -- Calculate the scaling factor to fit the image based on height
            if screenHeight < self.background.height then
                self.background.scaleFactor = screenHeight / self.background.height
            else
                self.background.scaleFactor = 1 -- no scaling if the image fits the screen
            end
        end
    }

    return game
end

return Game
