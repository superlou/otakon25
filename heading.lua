require "color_util"
require "text_util"
local tw = require "tween"
local class = require "middleclass"

-- Base heading that all headings are made from
local BaseHeading = class("BaseHeading")

function BaseHeading:initialize(text, heading_style)
    self.text = text
    self.is_blank = (text == "")
    self.font = heading_style.font
    self.font_size = heading_style.font_size or 50
    self.text_color = {hex2rgb(heading_style.text_color or "000000")}
end

function BaseHeading:draw()
    if self.is_blank then return end

    local text_r, text_g, text_b = unpack(self.text_color)
    write_centered(
        self.font, 0, 0, self.text, self.font_size,
        text_r, text_g, text_b, 1
    )
end

function BaseHeading:start_exit()
end

-- Heading that looks like a box or button
local BoxHeading = class("BoxHeading", BaseHeading)

function BoxHeading:initialize(text, heading_style)
    BaseHeading.initialize(self, text, heading_style)
    self.bg_resource = create_color_resource_hex(heading_style.bg_color)
    self.shadow_resource = create_color_resource_hex(heading_style.shadow_color)
    self.padding = heading_style.padding or 0

    local font_w = self.font:width(self.text, self.font_size)
    self.box_x_left = -(font_w / 2 + self.padding)
    self.box_x_right = (font_w / 2 + self.padding)

    self.y_offset_animation = 0
    self.text_alpha = 1
    tw:tween(self, "y_offset_animation", 8, 0, 0.5)
end

function BoxHeading:draw()
    if self.is_blank then return end
    
    local text_r, text_g, text_b = unpack(self.text_color)
    local font_w = self.font:width(self.text, self.font_size)

    self.shadow_resource:draw(
        self.box_x_left, self.font_size + 16,
        self.box_x_right, self.font_size + 16 + 8
    )

    self.bg_resource:draw(
        self.box_x_left, -24 + self.y_offset_animation,
        self.box_x_right, self.font_size + 16 + self.y_offset_animation
    )

    write_centered(
        self.font, 0, self.y_offset_animation, self.text, self.font_size,
        text_r, text_g, text_b, self.text_alpha
    )
end

function BoxHeading:start_exit()
    tw:tween(self, "text_alpha", 1, 0, 0.2)
    tw:tween(self, "box_x_left", self.box_x_left, self.box_x_right, 0.5)
end

-- Heading that is underlined text
local UnderlineHeading = class("UnderlineHeading", BaseHeading)

function UnderlineHeading:initialize(text, heading_style)
    BaseHeading.initialize(self, text, heading_style)
    self.shadow_resource = create_color_resource_hex(heading_style.shadow_color)
    self.padding = heading_style.padding or 0

    self.text_y_offset = 0
    self.text_alpha = 0
    self.width_animator = 0
    tw:tween(self, "text_y_offset", 40, 0, 0.5)
    tw:tween(self, "text_alpha", 0, 1, 0.5)
    tw:tween(self, "width_animator", 0.8, 1, 0.5)
end

function UnderlineHeading:draw()
    if self.is_blank then return end    
    local text_r, text_g, text_b = unpack(self.text_color)
    local font_w = self.font:width(self.text, self.font_size)

    self.shadow_resource:draw(
        -(font_w / 2 + self.padding) * self.width_animator, self.font_size + 16,
        (font_w / 2 + self.padding) * self.width_animator, self.font_size + 16 + 8
    )

    write_centered(
        self.font, 0, self.text_y_offset, self.text, self.font_size,
        text_r, text_g, text_b, self.text_alpha
    )
end

function UnderlineHeading:start_exit()
    tw:tween(self, "text_alpha", 1, 0, 0.5)
    tw:tween(self, "width_animator", 1, 0, 0.5)
end

-- This is a factory for heading types based on style
function Heading(text, heading_style)
    local style_classes = {
        underline = UnderlineHeading,
        box = BoxHeading,
    }

    local cls = style_classes[heading_style.style] or BaseHeading
    return cls(text, heading_style)
end

return Heading