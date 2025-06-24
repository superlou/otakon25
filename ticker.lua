require "color_util"
local class = require "middleclass"

local Ticker = class("Ticker")
local TickerMsg = class("TickerMsg")

local font = resource.load_font "font_Poppins-Regular.ttf"
local separator = resource.load_image("img_separator.png")
local msg_y_offset = 32

function Ticker:initialize()
end

function Ticker:initialize(x, y, w, h)
    self.x, self.y = x, y
    self.w, self.h = w, h
    self.bg = create_color_resource_hex("2b364c")
    self.speed = 1
    self.msgs = {}
    self.ticker_msgs = {}
    self.next_msg_id = 1
    self.font = font
    self.viewing_area_end = self.x + self.w
end

function Ticker:set_speed(speed)
    self.speed = speed
end

function Ticker:set_msgs_from_config(config)
    self.msgs = {}
    for i, item in ipairs(config.ticker_msgs) do
        self.msgs[i] = item.ticker_text_msg
    end
end

function Ticker:draw()
    self.bg:draw(self.x, self.y, self.x + self.w, self.y + self.h)

    -- Populate the first TickerMsg if there are none
    if #self.ticker_msgs == 0 then
        self.ticker_msgs[1] = TickerMsg(
            self.msgs[self.next_msg_id],
            self.x, self.y + msg_y_offset, self.font, 48
        )
        self.next_msg_id = self.next_msg_id + 1
    end

    -- Reset back to 1 if there is only 1 message
    if self.next_msg_id > #self.msgs then
        self.next_msg_id = 1
    end

    -- Add additional TickerMsgs until they span the viewing area
    while self:last_msg_end_x() < self.viewing_area_end do
        self.ticker_msgs[#self.ticker_msgs + 1] = TickerMsg(
            self.msgs[self.next_msg_id],
            self:last_msg_end_x(), self.y + msg_y_offset, self.font, 48
        )
    
        self.next_msg_id = self.next_msg_id + 1
        if self.next_msg_id > #self.msgs then self.next_msg_id = 1 end
    end

    -- Draw the TickerMsgs
    for i, ticker_msg in ipairs(self.ticker_msgs) do
        ticker_msg:draw()
        ticker_msg:shift_left(self.speed)
    end

    -- Prune any TickerMsgs that are no longer visible
    while self:first_msg_end_x() < self.x do
        table.remove(self.ticker_msgs, 1)
    end
end

function Ticker:first_msg_end_x()
    return self.ticker_msgs[1]:end_x()
end

function Ticker:last_msg_end_x()
    return self.ticker_msgs[#self.ticker_msgs]:end_x()
end

function TickerMsg:initialize(text, x, y, font, size)
    self.text = text
    self.x, self.y = x, y
    self.font = font
    self.size = size
    self.width = self.font:width(self.text, self.size)
end

function TickerMsg:draw()
    local text_width = self.font:write(self.x, self.y, self.text, self.size, 1, 1, 1, 1)
    local width, height = 64, 64
    local x_offset = 20
    local y_offset = -8
    separator:draw(
        self.x + text_width + x_offset, self.y + y_offset,
        self.x + text_width + width + x_offset, self.y + height + y_offset,
        1
    )
end

function TickerMsg:shift_left(delta)
    self.x = self.x - delta
end

function TickerMsg:end_x()
    return self.x + self.width + 100
end

return Ticker