require('Components.SFX')
Debugging = false 
Opacity = 1
Sfx = SFX()
function CalculateGlobals()
    WindowWidth, WindowHeight = love.graphics.getDimensions()
    GlobalScale = {x = WindowWidth / 1280 * 0.75, y = WindowHeight / 720 * 0.75}
end
CalculateGlobals()
function TriggerExplosions(explosion, x, y , scale)
    explosion.x, explosion.y = x, y
    explosion.sprite.spriteScale = { x = scale * GlobalScale.x, y = scale * GlobalScale.y }
    explosion.animation.currentFrame = 1
    explosion.animation.isPlaying = true
end

Shader = love.graphics.newShader[[
extern float WhiteFactor;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(WhiteFactor);
    return outputcolor;
}
]]
-- Define the shader
BlinkShader = love.graphics.newShader[[
    extern float alpha;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        return vec4(pixel.rgb, pixel.a * alpha);
    }
]]
Glow = love.graphics.newShader[[
extern number outlineSize;    // Size of the outline
extern vec4 outlineColor;     // Color of the outline
extern number bloomThreshold; // Brightness threshold for bloom
extern number bloomIntensity; // Intensity of the bloom

vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
    vec4 texColor = Texel(texture, textureCoords);
    
    // Outline effect
    if (texColor.a == 0.0) {
        for (float x = -outlineSize; x <= outlineSize; x++) {
            for (float y = -outlineSize; y <= outlineSize; y++) {
                vec4 neighborTex = Texel(texture, textureCoords + vec2(x, y) / love_ScreenSize.xy);
                if (neighborTex.a > 0.0) {
                    return outlineColor;  // Apply outline color to edge pixels
                }
            }
        }
    }

    // Bloom effect
    vec4 bloomColor = vec4(0.0);
    if (texColor.r > bloomThreshold || texColor.g > bloomThreshold || texColor.b > bloomThreshold) {
        bloomColor = texColor * bloomIntensity;
    }

    return texColor + bloomColor * color.a;  // Combine original color with bloom
}
]]
