require "globals"
local Player = require('Objects.Player')
local Game = require('States.Game')
local Menu = require('States.Menu')
local Enemy = require('Objects.Enemy')
local Sprite= require('Components.Sprite')
local Asteroid = require('Objects.Asteroid')
-- Variables for firing control
local fireRate = 0.25 -- Time in seconds between each bullet
local timeSinceLastShot = 0 -- Timer to track time between shots
--seed the random number generator
math.randomseed(os.time())
local game, player, enemy, menu, explosion, asteroid
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
    CalculateGlobals()
    game = Game()
    player = Player:new()
    enemy = Enemy:new()
    menu = Menu.new(game, player, enemy)
    asteroid = Asteroid.new()
    explosion = Sprite.new(
        {
            spritePath = 'Assets/spritesheet.png',
            animationFrames = 11,
            frameTime = 0.08,
            spriteScale = { x = 0.6, y = 0.6 }
        }
    )
    explosion.animation.isPlaying = false
    explosion.animation.playOnce = true

end

function love.update(dt)
    game:update(dt)
    if game.state["running"] then
        if game.lives > 0 then
            -- Update the timer
            timeSinceLastShot = timeSinceLastShot + dt
            
            -- Check if the left mouse button is held down and enough time has passed since the last shot
            if love.mouse.isDown(1) and timeSinceLastShot >= fireRate then
                player:fireBullets()  -- Fire bullets
                timeSinceLastShot = 0 -- Reset the timer
            end
            if player.ship:collisions(enemy.ship.hitboxes) or player.ship:collisions(enemy.laser.hitboxes)then
                if not Debugging then game.lives = game.lives - 1 end
                explosion.x = player.ship.position.x
                explosion.y = player.ship.position.y
                explosion.animation.isPlaying = true
                player.ship.position.x = 0 + player.ship.hitboxes[1].radius 
                player.ship.position.y = WindowHeight / 2
                player.ship.angle = 0
            end
            player:move(dt)
            asteroid:update(dt)
            asteroid:collision(player.ship.hitboxes)
            player.ship:update(dt)
            enemy.ship:update(dt)
            if love.keyboard.isDown('space') then
                game.lives = 0
                explosion.x = player.ship.position.x
                explosion.y = player.ship.position.y
                explosion.animation.isPlaying = true
            end
        end
        -- Update bullets
        local debugOffsetX = 0
        local debugOffsetY = 10
        player:update(dt)
        player.ship:findHitbox(debugOffsetX, debugOffsetY)
        local hits = enemy.bullets.type1:collision(player.ship.hitboxes)
        hits = hits + enemy.bullets.type2:collision(player.ship.hitboxes)
        if hits > 0 and not Debugging then
            enemy.bullets.type1.list = {}
            enemy.bullets.type2.list = {}
            game.lives = game.lives - 1
            if game.lives == 0 then
                explosion.x = player.ship.position.x
                explosion.y = player.ship.position.y
                explosion.animation.isPlaying = true
            end
        end
        hits = player.bullets:collision(enemy.ship.hitboxes)
        player.bullets:collision(asteroid.list)
        player.bullets:collision(enemy.bullets.type2.list)
        if hits > 0 and enemy.life > 0 then
            enemy.life = enemy.life - hits
        end
        -- Explosion animation logic
        explosion:updateAnimation(dt)
        enemy:update(dt, player)
    elseif game.state["menu"] then
    end
end

function love.draw()
    -- Draw the ship if it has lives
    if game.state["running"] then
        game:draw()
        asteroid:draw()
        --Draw Background
        if game.lives > 0 then
            love.graphics.print('Lives: ' .. game.lives, 10, 10)
            love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 30)
            explosion:draw()
            player:draw()
            enemy:draw()

        else
            -- Draw explosion if no lives left
            enemy:draw()
            if explosion.animation.isPlaying then
                explosion:draw()
                love.graphics.print('Game Over', 10, 10)
            else
                game:changeGameState("over")
            end
        end
    elseif game.state["menu"] then -- if we're at the menu, draw the buttons
        local r, g, b = love.graphics.getColor()
        love.graphics.setColor(r, g, b, 0.5)
        game:draw()
        love.graphics.setColor(r, g, b, 1)
        menu:draw("main")
        asteroid:draw()
        love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 10)
        love.graphics.setFont(love.graphics.newFont(55))
        love.graphics.printf("Ezz can't think of a title", 0, WindowHeight / 4, WindowWidth, "center")
        love.graphics.setFont(love.graphics.newFont(12))
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
            asteroid:draw()
            -- Draw bullets
            love.graphics.setColor(r, g, b, 1)
            love.graphics.setFont(love.graphics.newFont(30))
            love.graphics.printf('Paused', 0, WindowHeight / 2 - 50, WindowWidth, 'center')
            love.graphics.setFont(love.graphics.newFont(15))
            love.graphics.printf('Press ESC to resume', 0, WindowHeight / 2 + 50, WindowWidth, 'center')
            love.graphics.setFont(love.graphics.newFont(12))
        else
            -- Draw explosion if no lives left
            if explosion.animation.isPlaying then
                love.graphics.print('Game Over', 10, 10)
                local r, g, b = love.graphics.getColor()
                love.graphics.setColor(r, g, b, 0.5)
                game:draw()
                enemy:draw()
                explosion:draw()
                love.graphics.setColor(r, g, b, 1)
                love.graphics.print('Paused', WindowWidth / 2 - 30, WindowHeight / 2)
            end
        end
    end
end