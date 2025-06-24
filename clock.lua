local class = require "middleclass"
require "color_util"

local Clock = class("Clock")

local font = resource.load_font "font_Poppins-Regular.ttf"
local font_bold = resource.load_font "font_Poppins-Regular.ttf"
local debug_bg = create_color_resource_hex("ffffff", 0.4)
local date_bg = resource.load_image("img_date_bg.png")
local date_color = {hex2rgb("#da6339")}

function Clock:initialize(w, h, show_rect)
    self.w, self.h = w, h
    self.hh_mm = ""
    self.am_pm = ""
    self.month = ""
    self.day = ""
    self.date = ""
    self.spacing = 8
    self.show_rect = show_rect or false
end

function Clock:update(hh_mm, am_pm, month, day)
    self.hh_mm = hh_mm
    self.am_pm = am_pm
    self.month = month
    self.day = day
    self.date = string.upper(self.month) .. " " .. self.day
end

function Clock:draw()
    local w, h = self.w, self.h
    local text_h = 43
    local sub_h = 22

    if self.show_rect then
        debug_bg:draw(0, 0, w, h)
    end

    local x_anchor = 140
    local y_anchor = 60

    local hh_mm_w = font:width(self.hh_mm, text_h)
    local am_pm_w = font:width(self.am_pm, sub_h)
    local date_w = font:width(self.date, sub_h)
    local clock_w = hh_mm_w + self.spacing + am_pm_w
    local clock_h = text_h

    font:write(x_anchor - hh_mm_w, y_anchor - text_h,
               self.hh_mm, text_h,
               1, 1, 1, 1)

    font:write(x_anchor + 4, y_anchor - text_h + 2,
               self.am_pm, sub_h,
               1, 1, 1, 1)
    
    date_bg:draw(x_anchor - 90, y_anchor, x_anchor, y_anchor + sub_h + 4)

    local date_r, date_g, date_b = unpack(date_color)

    font_bold:write(x_anchor - date_w - 8, y_anchor + 3,
                    self.date, sub_h,
                    date_r, date_g, date_b, 1)

end

return Clock