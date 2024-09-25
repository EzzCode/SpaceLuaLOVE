local Button = require 'Objects.Button'

local Menu = {}
Menu.__index = Menu

function Menu.new(game, player, enemy)
    local self = setmetatable({}, Menu)
    self.game = game
    self.player = player
    self.enemy = enemy
    
    self.buttons = {
        main = self:createMainMenuButtons(),
        over = self:createGameOverButtons()
    }
    
    return self
end

function Menu:createMainMenuButtons()
    return {
        Button:new("Play Game", function() self.game:startGame(self.player, self.enemy) end, nil, 120, 40),
        Button:new("FullScreen", function() self.game:fullscreenToggle() end, nil, 120, 40),
        Button:new("Exit Game", love.event.quit, nil, 120, 40)
    }
end

function Menu:createGameOverButtons()
    return {
        Button:new("Play Again", function() self.game:startGame(self.player, self.enemy) end, nil, 120, 40),
        Button:new("Menu", function() self.game:changeGameState("menu") end, nil, 120, 40),
        Button:new("Exit Game", love.event.quit, nil, 120, 40)
    }
end

function Menu:draw(state)
    local buttonX = WindowWidth * 0.5 - 60
    local buttonY = {
        WindowHeight * 0.5,
        WindowHeight * 0.6667,
        WindowHeight * 0.8333
    }

    local buttons = self.buttons[state]
    if buttons then
        for i, button in ipairs(buttons) do
            button:draw(buttonX, buttonY[i])
        end
    end
end

function Menu:mousepressed(x, y, button)
    if button == 1 then
        local currentState = self.game.state.menu and "main" or (self.game.state.over and "over" or nil)
        if currentState then
            for _, btn in ipairs(self.buttons[currentState]) do
                btn:checkPressed(x, y)
            end
        end
    end
end

return Menu