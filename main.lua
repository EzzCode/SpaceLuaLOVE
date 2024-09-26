require "globals"
local Player = require('Objects.Player')
local Game = require('States.Game')
local Enemy = require('Objects.Enemy')
local Sprite = require('Components.Sprite')
local Asteroid = require('Objects.Asteroid')
-- Variables for firing control
local fireRate = 0.25       -- Time in seconds between each bullet
local timeSinceLastShot = 0 -- Timer to track time between shots
--seed the random number generator
math.randomseed(os.time())
local game, player, enemy, explosion, asteroid
function love.mousepressed(x, y, button)
    if not game.state["running"] then
        game.menu:mousepressed(x, y, button)
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
    player = Player:new()
    enemy = Enemy:new()
    asteroid = Asteroid.new()
    game = Game:new(player, enemy, asteroid)
    asteroid.spawnTimer = 5
end

function love.update(dt)
    game:update(dt)
    player.explosion:updateAnimation(dt)
    if game.state["running"] then
        if game.lives > 0 then
            -- Update the timer
            timeSinceLastShot = timeSinceLastShot + dt

            -- Check if the left mouse button is held down and enough time has passed since the last shot
            if love.mouse.isDown(1) and timeSinceLastShot >= fireRate then
                player:fireBullets()  -- Fire bullets
                timeSinceLastShot = 0 -- Reset the timer
            end
            -- Check if the player is hit
            local flag = player.ship:collisions(enemy.ship.hitboxes)
            flag = player.ship:collisions(enemy.laser.hitboxes) or flag
            flag = asteroid:collision(player.ship.hitboxes) or flag

            if flag then
                if not Debugging and not player.hitFlag then game.lives = game.lives - 1 end
                if not player.hitFlag then
                    player:destroyShip()
                end
                player.hitFlag = true
            end
            player:update(dt)
            asteroid:update(dt)
            enemy.ship:update(dt)
            if love.keyboard.isDown('space') then
                game.lives = 0
                player:destroyShip()
            end
            -- Update bullets
            local debugOffsetX = 0
            local debugOffsetY = 10
            player.ship:findHitbox(debugOffsetX, debugOffsetY)
            local hits = enemy.bullets.type1:collision(player.ship.hitboxes)
            hits = hits + enemy.bullets.type2:collision(player.ship.hitboxes)

            if hits > 0 and not player.hitFlag then
                player.hitFlag = true
                if not Debugging then game.lives = game.lives - 1 end
                if game.lives == 0 then
                    player:destroyShip()
                end
            end
            hits = player.bullets:collision(enemy.ship.hitboxes)
            player.bullets:collision(asteroid.list)
            player.bullets:collision(enemy.bullets.type2.list)
            if hits > 0 and enemy.life > 0 then
                enemy.life = enemy.life - hits
            end
        end
        enemy:update(dt, player)
    elseif game.state["menu"] then
    end
end

function love.draw()
    -- Draw the ship if it has lives
    if game.state["running"] then
        game:draw()
        if game.lives > 0 then
            player.explosion:draw()
        else
            if player.explosion.animation.isPlaying then
                player.explosion:draw()
            else
                game:changeGameState("over")
            end
        end
    elseif game.state["paused"] then
        if game.lives > 0 then
            game:draw()
        else
            -- Draw explosion if no lives left
            if player.explosion.animation.isPlaying then
                local r, g, b = love.graphics.getColor()
                love.graphics.setColor(r, g, b, 0.5)
                game:draw()
                enemy:draw()
                player.explosion:draw()
                love.graphics.setColor(r, g, b, 1)
                love.graphics.print('Paused', WindowWidth / 2 - 30, WindowHeight / 2)
            end
        end
    else
        game:draw()
    end
end