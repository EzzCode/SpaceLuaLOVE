local Player = require('Objects.Player')
local Game = require('States.Game')
local Menu = require('States.Menu')
local Enemy = require('Objects.Enemy')
local Explosion = require('Objects.Explosion')
local game, player, enemy, menu, explosion
function love.mousepressed(x, y, button)
    if not game.state["running"] then      -- if game state is not running
        if button == 1 then                -- and the left mouse button is clicked
            if game.state["menu"] then     -- if the state is menu
                menu:mousepressed(x, y, button)
            elseif game.state["over"] then -- if the state is game over
                menu:mousepressed(x, y, button)
            end
        end
    else
        if button == 1 then
            player:fireBullets()
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        if game.state["running"] then
            game:changeGameState("paused")
        elseif game.state["paused"] then
            game:changeGameState("running")
        end
    end
end

function love.load()
    -- Set up the screen dimensions
    game = Game()
    game.background:updateScaleFactor()
    player = Player:new()
    enemy = Enemy:new()
    menu = Menu.new(game, player)
    explosion = Explosion.new()
end

function love.update(dt)
    if game.state["running"] then
        -- Scroll the background horizontally (can also add vertical scrolling if needed)
        -- Scroll the background horizontally
        enemy.cannons.sprite.angle = enemy.cannons.sprite.angle + math.pi * dt
        game.background.x = (game.background.x + game.background.scrollSpeed * dt) %
        (game.background.width * game.background.scaleFactor)
        if game.lives > 0 then
            if player.ship:collisions(enemy.player.ship.hitboxes) then
                game.lives = game.lives - 1
                explosion:play(player.ship.position.x, player.ship.position.y)
                player.ship.position.x = 0 + player.ship.hitboxes[1].radius 
                player.ship.position.y = love.graphics.getHeight() / 2
                player.ship.angle = 0
            end
            player:move(dt)
            enemy:move(dt)
            player.ship.animation.elapsedTime = player.ship.animation.elapsedTime + dt
            if player.ship.animation.elapsedTime >= player.ship.animation.frameTime then
                player.ship.animation.currentFrame = player.ship.animation.currentFrame + 1
                player.ship.animation.elapsedTime = 0
            end
            if player.ship.animation.currentFrame > player.ship.animation.frames then
                player.ship.animation.currentFrame = 1
            end
            -- Handle explosion trigger
            if love.keyboard.isDown('space') then
                game.lives = 0
                explosion:play(player.ship.position.x, player.ship.position.y)
            end
        end
        -- Update bullets
        local debugOffsetX = 0
        local debugOffsetY = 10
        player:update(dt)
        player.ship:findHitbox(debugOffsetX, debugOffsetY)
        local hits = enemy.bullets.type1:collision(player.ship.hitboxes)
        if hits > 0 then
            enemy.bullets.type1.list = {}
            game.lives = game.lives - 1
            if game.lives == 0 then
                explosion:play(player.ship.position.x, player.ship.position.y)
            end
        end
        hits = player.bullets:collision(enemy.player.ship.hitboxes)
        if hits > 0 then
            enemy.life = enemy.life - hits
        end
        -- Explosion animation logic
        explosion:update(dt)
        enemy:update(dt, player)
    elseif game.state["paused"] then

    end
end

function love.draw()
    -- Draw the ship if it has lives
    if game.state["running"] then
        --Draw Background
        game:draw()
        if game.lives > 0 then
            love.graphics.print('Lives: ' .. game.lives, 10, 10)
            love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 30)
            explosion:draw()
            player:draw()
            enemy:draw()

        else
            -- Draw explosion if no lives left
            enemy:draw()
            if explosion.animation.playing then
                explosion:draw()
                love.graphics.print('Game Over', 10, 10)
            else
                game:changeGameState("over")
            end
        end
    elseif game.state["menu"] then -- if we're at the menu, draw the buttons
        menu:draw("main")
    elseif game.state["over"] then -- if we're at the game over screen, draw the buttons
        love.graphics.print('Game Over', 10, 10)
        menu:draw("over")
    elseif game.state["paused"] then
        if game.lives > 0 then
            love.graphics.print('Lives: ' .. game.lives, 10, 10)
            local r, g, b = love.graphics.getColor()
            love.graphics.setColor(r, g, b, 0.5)
            game:draw()
            player:draw()
            enemy:draw()

            -- Draw bullets
            love.graphics.setColor(r, g, b, 1)
            love.graphics.print('Paused', love.graphics.getWidth() / 2 - 30, love.graphics.getHeight() / 2)
        else
            -- Draw explosion if no lives left
            if explosion.animation.playing then
                love.graphics.print('Game Over', 10, 10)
                local r, g, b = love.graphics.getColor()
                love.graphics.setColor(r, g, b, 0.5)
                game:draw()
                enemy:draw()
                explosion:draw()
                love.graphics.setColor(r, g, b, 1)
                love.graphics.print('Paused', love.graphics.getWidth() / 2 - 30, love.graphics.getHeight() / 2)
            end
        end
    end
end