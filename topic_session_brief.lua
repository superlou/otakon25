local class = require "middleclass"
local Topic = require "topic"
local tw = require "tween"
local json = require "json"
local Pager = require "pager"
require "sessions_filter"
require "text_util"
require "color_util"
require "file_util"

local SessionBriefTopic = class("SessionBriefTopic", Topic)
local SessionBriefItem = class("SessionBriefItem")

function SessionBriefTopic:initialize(player, w, h, style, duration, heading, text, media)
    Topic.initialize(self, player, w, h, style, duration)
    self.heading = heading
    self.text = text
    self.text_color = {hex2rgb(self.style.text.color)}
    self.font_size = 40

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
    self.item_gap = 15

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

function SessionBriefTopic:load_page()
    local sessions = table.remove(self.sessions_by_page, 1)
    self.session_items = {}
    
    for i, session in ipairs(sessions) do
        local item = SessionBriefItem:new(
            session.name, session.locations,
            session.start_hhmm, session.start_ampm,
            session.finish_hhmm, session.finish_ampm,
            session.is_before_start, session.is_open, session.is_after_finish,
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

function SessionBriefTopic:draw()
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

function SessionBriefItem:initialize(name, locations,
        start_hhmm, start_ampm,
        finish_hhmm, finish_ampm,
        is_before_start, is_open, is_after_finish,
        w, h, duration, enter_delay, style
)
    self.name = name
    self.locations = locations
    self.start_hhmm = start_hhmm
    self.start_ampm = start_ampm
    self.finish_hhmm = finish_hhmm
    self.finish_ampm = finish_ampm
    self.is_before_start = is_before_start
    self.is_open = is_open
    self.is_after_finish = is_after_finish
    self.w, self.h = w, h
    self.duration = duration
    self.style = style
    self.bg_img = self.style.session_brief.item_bg_img

    self.start = self.start_hhmm .. string.sub(self.start_ampm, 1, 1)
    self.finish = self.finish_hhmm .. string.sub(self.finish_ampm, 1, 1)

    self.status1 = ""
    self.status2 = ""

    if self.is_before_start then
        self.status1 = "opens"
        self.status2 = self.start
    elseif self.is_open then
        self.status1 = "until"
        self.status2 = self.finish
    else
        self.status1 = "closed"
        self.status2 = " "
    end

    self.text_color = {hex2rgb(self.style.text.color)}
    self.font_size = 50
    self.font = self.style.text.font

    -- Calculations to right align
    self.date_w = 120
    self.start_hhmm_x = self.date_w - self.font:width(self.start_hhmm, self.font_size)
    self.start_ampm_x = self.date_w - self.font:width(self.start_ampm, self.font_size * 0.8)

    self.alpha = 0

    tw:tween(self, "alpha", 0, 1, 0.5):delay(enter_delay)
    tw:timer(self.duration):on_done(function()
        tw:tween(self, "alpha", 1, 0, 0.5)
    end)
end

local until_color = {hex2rgb("#2fc480")}
local opens_color = {hex2rgb("#d9b630")}
local closed_color = {hex2rgb("#d34848")}

local img_until = resource.load_image("img_until_dark.png")
local img_closed = resource.load_image("img_ended_dark.png")
local img_opens = resource.load_image("img_opens_dark.png")
local img_none = resource.load_image("img_no_media.png")

function SessionBriefItem:draw()
    local r, g, b = unpack(self.text_color)

    if self.bg_img then
        self.bg_img:draw(20, -10, self.w - 20, 0 + self.h, self.alpha)
    end

    local status_img = img_none
    local status_color = {1, 1, 1}

    if self.status1 == "opens" then
        status_img = img_opens
        status_color = opens_color
    elseif self.status1 == "until" then
        status_img = img_until
        status_color = until_color
    elseif self.status1 == "closed" then
        status_img = img_closed
        status_color = closed_color
    end
    
    status_img:draw(490, 13, 490 + 82, 13 + 25, self.alpha)
    write_centered(
        self.font, 490 + 41, 50, self.status2, self.font_size * 0.5,
        status_color[1], status_color[2], status_color[3], self.alpha
    )

    draw_text_in_window(
        self.name,
        40, 0, 435,
        self.font_size, self.font_size, self.font,
        r, g, b, self.alpha, 0
    )

    if #self.locations > 0 then
        self.font:write(
            40, 60, self.locations[1], self.font_size * 0.5,
            r, g, b, self.alpha
        )
    end
end

return SessionBriefTopic
