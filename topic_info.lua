require "color_util"
local class = require "middleclass"
local Topic = require "topic"
require "text_util"
local tw = require "tween"
local Heading = require "heading"
local offset = require "offset"

local InfoTopic = class("InfoTopic", Topic)

function InfoTopic:initialize(player, w, h, style, duration, heading, text, media)
    Topic.initialize(self, player, w, h, style, duration)
    self.text = text
    self.text_color = {hex2rgb(
        (style.info and style.info.text_color) or style.text.color
    )}
    self.text_frame = style.info and style.info.text_frame
    self.font_size = 40

    self:use_background_media(media, style.player_bg_mask)

    self.style = style
    self.padding = self.style.padding
    self.content_w = self.w - self.padding[2] - self.padding[4]
    self.lines = wrap_text(self.text, self.style.text.font, self.font_size, self.content_w)
    self.bg_alpha = 0
    self.text_alpha = 0
    self.y_offset = 0

    self.heading = Heading(heading, style.heading)

    tw:tween(self, "bg_alpha", 0, 1, 0.5)
    tw:tween(self, "text_alpha", 0, 1, 0.5)
    tw:tween(self, "y_offset", 20, 0, 0.5)

    tw:timer(self.duration):on_done(function()
        self.heading:start_exit()
        tw:tween(self, "text_alpha", 1, 0, 0.5)
    end):then_after(0.5, function()
        if not self:next_topic_has_bg() then tw:tween(self, "bg_alpha", 1, 0, 0.5) end
        self:set_exiting()
    end):then_after(0.5, function()
        self:set_done()
    end)
end

function InfoTopic:draw()
    local r, g, b = unpack(self.text_color)
    self:draw_background_media(self.bg_alpha)

    local heading_x = self.w / 2
    local heading_y = self.style.padding[1]

    offset(heading_x, heading_y, function()
        self.heading:draw()
    end)

    local message_y = self.style.padding[1] + 80
    local message_y_limit = self.h - self.style.padding[3]

    offset(0, message_y - self.y_offset, function()
        if #self.lines > 0 and self.text_frame then
            self.text_frame:draw(
                self.padding[4] - 10,
                self.font_size * 1.5 - 10,
                self.w - self.padding[2] + 10,
                self.font_size * 1.5 * (#self.lines + 1 ),
                self.text_alpha
            )
        end

        for i, line in ipairs(self.lines) do
            local line_x = self.padding[4]
            local line_y = i * self.font_size * 1.5
            local line_y_bottom = line_y + self.font_size

            if (line_y_bottom + message_y) > message_y_limit then
                break
            end

            self.style.text.font:write(
                line_x, line_y, line, self.font_size,
                r, g, b, self.text_alpha
            )
        end
    end)
end

return InfoTopic