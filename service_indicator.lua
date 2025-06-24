local class = require "middleclass"
local tw = require "tween"
local font = resource.load_font "font_Poppins-Regular.ttf"

local ServiceIndicator = class("ServiceIndicator")

local icons = {}
util.resource_loader({
    "img_triangle_down_white.png",
    "img_triangle_down_white_solid.png",
    "img_triangle_down_green.png",
    "img_triangle_down_yellow.png",
    "img_circle_white.png",
    "img_circle_white_solid.png",
    "img_circle_yellow.png",
    "img_circle_green.png",
}, icons)

local UNKNOWN = 0
local OK = 1
local IN_PROGRESS = 2
local FAIL = 3

function ServiceIndicator:initialize()
    self.updating = false
    self.desc = ""
    self.alpha = 0
    self.checks = {
        fetch = UNKNOWN,
        process = UNKNOWN,
        write = UNKNOWN,
        cache = UNKNOWN,
    }
end

function checks_all_ok(checks)
    return checks.fetch == 1 and
           checks.process == 1 and
           checks.write == 1 and
           checks.cache == 1
end

function ServiceIndicator:update(updating, checks, desc)
    if not self.updating and updating then
        tw:tween(self, "alpha", 0, 1, 0.5)
    elseif self.updating and not updating and checks_all_ok(checks) then
        tw:tween(self, "alpha", 1, 0, 0.5)
    end

    self.updating = updating
    self.checks = checks
    self.desc = desc
end


function image_for_status(status, img_default, img_ok, img_fail)
    if status == OK then
        return img_ok
    elseif status == FAIL then
        return img_fail
    end

    return img_default
end


function ServiceIndicator:draw()
    local img_fetch = image_for_status(
        self.checks.fetch,
        icons.img_triangle_down_white,
        icons.img_triangle_down_white_solid,
        icons.img_triangle_down_yellow
    )

    local img_process = image_for_status(
        self.checks.process,
        icons.img_circle_white,
        icons.img_circle_white_solid,
        icons.img_circle_yellow
    )

    local img_write = image_for_status(
        self.checks.write,
        icons.img_circle_white,
        icons.img_circle_white_solid,
        icons.img_circle_yellow
    )

    local img_cache = image_for_status(
        self.checks.cache,
        icons.img_circle_white,
        icons.img_circle_white_solid,
        icons.img_circle_yellow
    )

    img_fetch:draw(0, 0, 16, 14, self.alpha)
    offset(0, 21, function()
        img_process:draw(0, 0, 15, 15, self.alpha)
    end)
    offset(0, 42, function()
        img_write:draw(0, 0, 15, 15, self.alpha)
    end)
    offset(0, 64, function()
        img_cache:draw(0, 0, 15, 15, self.alpha)
    end)        
end

return ServiceIndicator