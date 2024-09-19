local Button = require 'Objects.Button'

local Menu = {}
Menu.__index = Menu

function Menu.new(game, player)
    local self = setmetatable({}, Menu)
    self.game = game
    self.player = player
    
    self.func = {
        newGame = function()
            self.game:startGame(self.player)
        end,
        quit = function()
            love.event.quit()
        end,
        fullScreen = function()
            love.window.setFullscreen(not love.window.getFullscreen())
                        -- Recalculate screen dimensions and scale factor
            screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
            
            -- Recalculate the scale factor to fit the background image
            if screenHeight < backgroundImageHeight then
                scaleFactor = screenHeight / backgroundImageHeight
            else
                scaleFactor = 1 -- no scaling if the image fits the screen
            end
        end,
        changeGameState = function(state)
            self.game:changeGameState(state)
        end
    }
    
    self.buttons = {
        main = {
            Button:new("Play Game", self.func.newGame, nil, 120, 40),
            Button:new("Settings", self.func.fullScreen, nil, 120, 40),
            Button:new("Exit Game", self.func.quit, nil, 120, 40)
        },
        over = {
            Button:new("Play Again", self.func.newGame, nil, 120, 40),
            Button:new("Menu", self.func.changeGameState, "menu", 120, 40),
            Button:new("Exit Game", self.func.quit, nil, 120, 40)
        }
    }
    
    return self
end

function Menu:draw(state)
    -- local buttons = self.buttons[state]
    -- for i, button in ipairs(buttons) do
    --     button:draw(love.graphics.getWidth() / 2 - button.width / 2, 100 + (i - 1) * 60)
    -- end
    -- Get the current window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Calculate relative positions for buttons based on the window size
    local playX = windowWidth * (400 / 800) - 60  -- Horizontal position
    local playY = windowHeight * (300 / 600)      -- "Play" button Y position
    local settingsY = windowHeight * (400 / 600)  -- "Settings" button Y position
    local exitY = windowHeight * (500 / 600)      -- "Exit" button Y position

    -- Select the button set based on the current state
    local buttons
    if state == "main" then
        buttons = self.buttons.main
    elseif state == "over" then
        buttons = self.buttons.over
    end

    -- Draw buttons at relative positions
    if buttons then
        buttons[1]:draw(playX, playY)           -- "Play Game" or "Play Again"
        buttons[2]:draw(playX, settingsY)       -- "Settings" or "Menu"
        buttons[3]:draw(playX, exitY)           -- "Exit Game"
    end
    
end

function Menu:update(dt)
    -- Add any menu-specific update logic here if needed
end

function Menu:mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        local currentState = self.game.state.menu and "main" or (self.game.state.over and "over" or nil)
        if currentState then
            for _, btn in ipairs(self.buttons[currentState]) do
                btn:checkPressed(x, y)
            end
        end
    end
end



return Menu