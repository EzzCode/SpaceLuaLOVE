local button = require('Objects.Button')
local Player = require('Objects.Player')
local Game = require('States.Game')
local Menu = require('States.Menu')

local backgroundImage


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
            Player:fireBullets()
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
    -- Load the background image (ensure it's 3000x1000)
    game = Game()
    Player = Player:new()
    menu = Menu.new(game, Player)

    backgroundImage = love.graphics.newImage("Assets/Space Background1.png")

    -- Get the dimensions of the image
    backgroundImageWidth = backgroundImage:getWidth()
    backgroundImageHeight = backgroundImage:getHeight()
    -- Set up the screen dimensions
    screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

    -- Calculate the scaling factor to fit the image based on height
    if screenHeight < backgroundImageHeight then
        scaleFactor = screenHeight / backgroundImageHeight
    else
        scaleFactor = 1 -- no scaling if the image fits the screen
    end
    -- Initial position and speed for background scrolling
    backgroundScrollSpeed = 100 -- pixels per second
    backgroundX = 0
    backgroundY = 0


    -- Explosion properties
    _G.explosion = {
        x = 0,
        y = 0,
        sprite = {
            image = love.graphics.newImage('Assets/spritesheet.png'),
            height = 359,
            width = 4334,
            quad_width = 394,
            quad_height = 359,
        },
        animation = {
            frames = 11,
            current_frame = 1,
            time = 0.08,
            current_time = 0,
            playing = false
        }
    }

    -- Quads for the explosion animation
    Quads = {}
    for i = 1, explosion.animation.frames do
        Quads[i] = love.graphics.newQuad(
            explosion.sprite.quad_width * (i - 1),
            0,
            explosion.sprite.quad_width,
            explosion.sprite.quad_height,
            explosion.sprite.width,
            explosion.sprite.height
        )
    end
end

function love.update(dt)
    if game.state["running"] then
        -- Scroll the background horizontally (can also add vertical scrolling if needed)
        -- Scroll the background horizontally
        backgroundX = (backgroundX + backgroundScrollSpeed * dt) % (backgroundImageWidth * scaleFactor)
        if game.lives > 0 then
            Player:move(dt)
            Player.ship.animation.elapsedTime = Player.ship.animation.elapsedTime + dt
            if Player.ship.animation.elapsedTime >= Player.ship.animation.frameTime then
                Player.ship.animation.currentFrame = Player.ship.animation.currentFrame + 1
                Player.ship.animation.elapsedTime = 0
            end
            if Player.ship.animation.currentFrame > Player.ship.animation.frames then
                Player.ship.animation.currentFrame = 1
            end
            -- Handle explosion trigger
            if love.keyboard.isDown('space') then
                game.lives = 0
                explosion.animation.playing = true
                explosion.x = Player.ship.position.x
                explosion.y = Player.ship.position.y
            end
        end
        -- Explosion animation logic
        if explosion.animation.playing then
            explosion.animation.current_time = explosion.animation.current_time + dt
            if explosion.animation.current_time >= explosion.animation.time then
                explosion.animation.current_frame = explosion.animation.current_frame + 1
                explosion.animation.current_time = 0
            end
            if explosion.animation.current_frame > explosion.animation.frames then
                explosion.animation.current_frame = 1
                explosion.animation.playing = false
            end
        end
        -- Update bullets
        Player:updateBullets(dt)
    elseif game.state["paused"] then

    end
end

function love.draw()
    -- Draw the ship if it has lives
    if game.state["running"] then
        -- Calculate how many tiles are needed horizontally and vertically
        local tilesX = math.ceil(screenWidth / backgroundImageWidth) + 1
        local tilesY = math.ceil(screenHeight / backgroundImageHeight) + 1

        -- Draw the tiled background with proper scrolling
        for x = 0, tilesX - 1 do
            for y = 0, tilesY - 1 do
                love.graphics.draw(backgroundImage, x * backgroundImageWidth * scaleFactor - backgroundX,
                    y * backgroundImageHeight * scaleFactor - backgroundY, 0, scaleFactor, scaleFactor)
            end
        end
        if game.lives > 0 then
            love.graphics.print('Lives: ' .. game.lives, 10, 10)
            love.graphics.print('FPS: ' .. love.timer.getFPS(), 10, 30)
            Player:draw()
            -- Draw bullets
            Player:drawBullets()
        else
            -- Draw explosion if no lives left
            if explosion.animation.playing then
                love.graphics.draw(
                    explosion.sprite.image,
                    Quads[explosion.animation.current_frame],
                    explosion.x,
                    explosion.y,
                    0,
                    0.6, 0.6,
                    explosion.sprite.quad_width / 2,
                    explosion.sprite.quad_height / 2
                )
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
            love.graphics.draw(backgroundImage, - backgroundX,
            - backgroundY, 0, scaleFactor, scaleFactor)
            
            Player:draw()
            -- Draw bullets
            Player:drawBullets()
            love.graphics.setColor(r, g, b, 1)
            love.graphics.print('Paused', love.graphics.getWidth() / 2 - 30, love.graphics.getHeight() / 2)
        else
            -- Draw explosion if no lives left
            if explosion.animation.playing then
                love.graphics.draw(
                    explosion.sprite.image,
                    Quads[explosion.animation.current_frame],
                    explosion.x,
                    explosion.y,
                    0,
                    0.6, 0.6,
                    explosion.sprite.quad_width / 2,
                    explosion.sprite.quad_height / 2
                )
                love.graphics.print('Game Over', 10, 10)
            end
        end
    end
end