local glass_main = resource.load_image "img_glass_main.png"
local glass1 = resource.load_image "img_glass1.png"
local glass2 = resource.load_image "img_glass2.png"
local glass3 = resource.load_image "img_glass3.png"
local glass4 = resource.load_image "img_glass4.png"

local t = 0

function draw_glass()
    glass_main:draw(781, 31, 781 + 965, 23 + 934)
    local x, y = 1150, 280
    glass1:draw(x, y, x + 123, y + 178, 0.2 * math.sin(2 * 3.1415 * 0.1 * t + 7) + 0.2)
    local x, y = 1345, 210
    glass2:draw(x, y, x + 100, y + 170, 0.2 * math.sin(2 * 3.1415 * 0.15 * t + 3.5) + 0.2)
    local x, y = 1175, 40
    glass3:draw(x, y, x + 160, y + 224, 0.5 * math.sin(2 * 3.1415 * 0.17 * t + 2) + 0.5)
    local x, y = 1290, 315
    glass4:draw(x, y, x + 52, y + 120, 0.3 * math.sin(2 * 3.1415 * 0.08 * t + 4.1) + 0.3)
    t = t + 1 / 60
end