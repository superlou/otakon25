local class = require "middleclass"
local Topic = require "topic"
local tw = require "tween"
local json = require "json"
local Pager = require "pager"
require "sessions_filter"
require "text_util"
require "color_util"
require "file_util"
require "table_util"

local SessionListTopic = class("SessionListTopic", Topic)
local SessionListItem = class("SessionListItem")

local white_img = resource.create_colored_texture(1, 1, 1, 1)
local green_img = create_color_resource_hex("#2fc480")
local red_img = create_color_resource_hex("#d34848")

function SessionListTopic:initialize(player, w, h, style, duration, heading, text, media)
    Topic.initialize(self, player, w, h, style, duration)
    self.heading = heading
    self.text = text
    self.text_color = {hex2rgb(self.style.text.color)}
    self.font_size = 36

    self:use_background_media(media, style.player_bg_mask)
    self.alpha = 0
    tw:tween(self, "alpha", 0, 1, 0.5)

    self.heading = Heading(heading, style.heading)
    
    local data_filename = text:match("data:([%w_.]+)")
    local session_data_text = file_load_safe(data_filename, "[]")
    self.sessions_data = json.decode(session_data_text)

    local filters = extract_session_filters_from_config(text)
    sessions_filter(self.sessions_data, filters)

    self.items_start_y = 210
    self.item_h = 100
    self.item_gap = 20

    local items_space = self.h - self.items_start_y - self.style.padding[3]
    self.sessions_per_page = math.floor(items_space / (self.item_h + self.item_gap))
    self.sessions_by_page = split_every_n(self.sessions_data, self.sessions_per_page)
    self.session_items = {}     -- the session drawing objects

    if #self.sessions_by_page == 0 then
        -- If nothing to show, wait for 1 page duration
        tw:timer(self.duration):on_done(function()
            self.heading:start_exit()
        end):then_after(0.5, function()
            if not self:next_topic_has_bg() then tw:tween(self, "alpha", 1, 0, 0.5) end
            self:set_exiting()
        end):then_after(0.5, function()
            self:set_done()
        end)
    else
        self:load_page()
    end

    -- todo I don't know why the length of the table is one less than expected
    -- Really only want pager if there is more than 1 page.
    if #self.sessions_by_page > 0 then
        -- todo I don't know why the following needs "+ 1"
        local pager_w = self.w - self.style.padding[2] - self.style.padding[4]
        self.pager = Pager(pager_w, #self.sessions_by_page + 1)
    end
end

function SessionListTopic:load_page()
    local sessions = table.remove(self.sessions_by_page, 1)
    self.session_items = {}

    for i, session in ipairs(sessions) do
        local item = SessionListItem:new(
            session.name, session.locations, session.start_hhmm, session.start_ampm,
            session.completed_fraction,
            self.w, self.item_h,
            self.duration,
            (i - 1) * 0.1,
            self.style
        )

        table.insert(self.session_items, item)
    end

    if #self.sessions_by_page > 0 then
        -- Need to exit the current page's sessions and load next ones
        tw:timer(self.duration + 0.5):on_done(function()
            self:load_page()
            if self.pager then
                self.pager:advance()
            end
        end)
    else
        -- No more session pages to show
        tw:timer(self.duration):on_done(function()
            self.heading:start_exit()
        end):then_after(0.5, function()
            if not self:next_topic_has_bg() then tw:tween(self, "alpha", 1, 0, 0.5) end
            self:set_exiting()
        end):then_after(0.5, function()
            self:set_done()
        end)
    end
end

function SessionListTopic:draw()
    local r, g, b = unpack(self.text_color)
    self:draw_background_media(self.alpha)

    local heading_x = self.w / 2
    local heading_y = self.style.padding[1]

    offset(heading_x, heading_y, function()
        self.heading:draw()
    end)

    for i, session_item in ipairs(self.session_items) do
        offset(0, self.items_start_y + (i - 1) * (self.item_h + self.item_gap), function()
            session_item:draw()
        end)
    end

    if self.pager then
        local pager_y = self.h - self.style.padding[3] - self.pager.h
        offset(self.style.padding[4], pager_y, function()
            self.pager:draw()
        end)
    end
end

function SessionListItem:initialize(name, locations, start_hhmm, start_ampm, 
    completed_fraction, w, h, duration, enter_delay, style
)
    self.name = name
    self.locations = locations
    self.start_hhmm = start_hhmm
    self.start_ampm = start_ampm
    self.completed_fraction = completed_fraction
    self.w, self.h = w, h
    self.duration = duration
    self.style = style
    self.padding = self.style.padding
    self.bg_img = self.style.session_list.item_bg_img
    self.compact = self.style.session_list.compact

    for i, location in ipairs(self.locations) do
        self.locations[i] = string.upper(location)
    end

    self.text_color = {hex2rgb(self.style.text.color)}
    self.font_size = 40
    self.font = self.style.text.font
    self.font_bold = self.style.text.font_bold

    -- Calculations to right align time text
    if self.compact then
        self.date_w = 50
        self.start_hhmm_x = self.padding[4] + self.date_w - self.font:width(self.start_hhmm, self.font_size * 0.55)
        self.start_ampm_x = self.padding[4] + self.date_w - self.font:width(self.start_ampm, self.font_size * 0.55)
    else
        self.date_w = 100
        self.start_hhmm_x = self.padding[4] + self.date_w - self.font:width(self.start_hhmm, self.font_size)
        self.start_ampm_x = self.padding[4] + self.date_w - self.font:width(self.start_ampm, self.font_size * 0.8)
    end

    self.alpha = 0

    tw:tween(self, "alpha", 0, 1, 0.5):delay(enter_delay)
    tw:timer(self.duration):on_done(function()
        tw:tween(self, "alpha", 1, 0, 0.5)
    end)
end

function SessionListItem:draw()
    if self.compact then
        self:draw_compact()
    else
        self:draw_normal()
    end
end

function SessionListItem:draw_normal()
    if self.bg_img then
        self.bg_img:draw(
            self.padding[2] / 2, -15,
            self.w - self.padding[4] / 2, -15 + self.h,
        self.alpha)
    end

    local r, g, b = unpack(self.text_color)

    self:draw_time()

    local name_x = self.padding[4] + self.date_w + 10
    local name_w = self.w - name_x - self.padding[2]

    draw_text_in_window(
        self.name,
        name_x, 0, name_w,
        self.font_size, self.font_size, self.font,
        r, g, b, self.alpha, 0
    )

    if #self.locations > 0 then
        self.font_bold:write(
            self.padding[4] + self.date_w + 14, 50, self.locations[1], self.font_size * 0.55,
            r, g, b, self.alpha
        )
    end
end

function SessionListItem:draw_time()
    local r, g, b = unpack(self.text_color)

    self.font:write(
        self.start_hhmm_x, 0, self.start_hhmm, self.font_size,
        r, g, b, self.alpha
    )

    self.font:write(
        self.start_ampm_x, 43, self.start_ampm, self.font_size * 0.8,
        r, g, b, self.alpha
    )

    local bar_y = 42
    local bar_h = 3
    local bar_w = self.date_w

    local fill_img = green_img
    if self.completed_fraction >= 0.9 then
        fill_img = red_img
    end

    white_img:draw(self.padding[4], bar_y, self.padding[4] + bar_w, bar_y + bar_h, self.alpha)
    fill_img:draw(self.padding[4], bar_y, self.padding[4] + bar_w * self.completed_fraction, bar_y + bar_h, self.alpha)
end

function SessionListItem:draw_compact()
    if self.bg_img then
        self.bg_img:draw(
            self.padding[2] / 2, -15,
            self.w - self.padding[4] / 2, -15 + self.h,
        self.alpha)
    end

    local r, g, b = unpack(self.text_color)

    -- self:draw_time()

    local name_x = self.padding[4]
    local name_w = self.w - name_x - self.padding[2]

    draw_text_in_window(
        self.name,
        name_x, 0, name_w,
        self.font_size, self.font_size, self.font,
        r, g, b, self.alpha, 0
    )

    self.font:write(
        self.start_hhmm_x, 50, self.start_hhmm, self.font_size * 0.55,
        r, g, b, self.alpha
    )

    if #self.locations > 0 then
        self.font_bold:write(
            self.padding[4] + self.date_w + 14, 50, self.locations[1], self.font_size * 0.55,
            r, g, b, self.alpha
        )
    end
end


return SessionListTopic
