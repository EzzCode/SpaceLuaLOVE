Debugging = false
function CalculateGlobals()
    WindowWidth, WindowHeight = love.graphics.getDimensions()
    GlobalScale = {x = WindowWidth / 1280 * 0.75, y = WindowHeight / 720 * 0.75}
end
