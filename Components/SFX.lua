function SFX()
    local bgm = love.audio.newSource("Assets/SFX/beyond-the-veil-242451.mp3", "stream")
    bgm:setVolume(0.6)
    bgm:setLooping(true)
    bgm:play()

    local effects = {
        laser = love.audio.newSource("Assets/SFX/LaserBeam-1 loud.mp3", "static"),
        bullet = love.audio.newSource("Assets/SFX/Bullet-1.mp3", "static"),
        bullet2 = love.audio.newSource("Assets/SFX/Bullet-2.1.mp3", "static"),
        bullet3 = love.audio.newSource("Assets/SFX/laser.ogg", "static"),
        warning = love.audio.newSource("Assets/SFX/alarm.mp3", "static"),
        explosion = love.audio.newSource("Assets/SFX/Explosion-1.mp3", "static"),
        explosion2 = love.audio.newSource("Assets/SFX/explosion_asteroid_out (1).ogg", "static"),
        hit = love.audio.newSource("Assets/SFX/Bullet-3.mp3", "static"),
        click = love.audio.newSource("Assets/SFX/Click.mp3", "static"),
        lose = love.audio.newSource("Assets/SFX/lose.mp3", "static"),
    }
    effects.lose:setVolume(0.3)
    effects.warning:setPitch(0.6)
    effects.bullet:setVolume(0.5)
    effects.bullet2:setVolume(0.5)
    effects.bullet3:setVolume(0.2)
    effects.warning:setVolume(0.7)
    effects.explosion:setVolume(0.7)
    effects.explosion2:setVolume(0.4)
    effects.explosion:setPitch(0.8)
    effects.bullet2:setPitch(1)
    return {
        fxPlayed = false,
        effects = effects,
        bgm = bgm,

        playBGM = function(self)
            if not self.bgm:isPlaying() then
                self.bgm:play()
            end
        end,

        stopBGM = function(self)
            if self.bgm:isPlaying() then
                self.bgm:pause()
            end
        end,

        stopFX = function(self, fx)
            if effects[fx]:isPlaying() then
                effects[fx]:stop()
            end
        end,

        playFX = function(self, fx, mode)
            if mode == "multi" then
                -- Clone the existing source to allow multiple instances of the same sound effect
                local fxClone = effects[fx]:clone()
                fxClone:play()
            elseif mode == "slow" then    
                if not effects[fx]:isPlaying() then
                    effects[fx]:play()
                end
            elseif mode == "single" then
                if not self.fxPlayed then
                    effects[fx]:play()
                    self.fxPlayed = true
                end
            else
                self:stopFX(fx)
                effects[fx]:play()
            end
        end,

        setVolume = function(self, volume)
            for _, v in pairs(effects) do
                v:setVolume(volume)
            end
        end
    }
end

return SFX
