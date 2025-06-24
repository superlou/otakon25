require "table_util"
local class = require "middleclass"

local TopicPlayer = class("TopicPlayer")
local InfoTopic = require "topic_info"
local SessionListTopic = require "topic_session_list"
local SessionBriefTopic = require "topic_session_brief"

function TopicPlayer:initialize(w, h, style, bg)
    self.w, self.h = w, h
    self.style = style
    self.bg = bg

    self.topic_configs = {}
    self.active_topic = nil
    self.next_topic = nil
    self.next_topic_id = 1
end

function TopicPlayer:set_topics_from_config(config)
    local serial_num = sys.get_env("SERIAL")

    filter_inplace(config, function(topic)
        return topic.device == "" or topic.device == serial_num
    end)

    filter_inplace(config, function(topic)
        return topic.disabled == nil or topic.disabled == false
    end)

    self.topic_configs = config
end

function TopicPlayer:draw()
    if #self.topic_configs == 0 then
        return
    end

    if self.bg then self.bg:draw(0, 0, self.w, self.h) end

    if self.active_topic == nil then
        self.active_topic = self:build_next_topic()
    end

    if self.active_topic:is_exiting() and self.next_topic == nil then
        self.next_topic = self:build_next_topic()
    elseif self.active_topic:is_done() and self.next_topic ~= nil then
        self.active_topic = self.next_topic
        self.next_topic = nil
    elseif self.active_topic:is_done() and self.next_topic == nil then
        self.active_topic = self:build_next_topic()
    end

    self.active_topic:draw()
    if self.next_topic then
        self.next_topic:draw()
    end
end

function TopicPlayer:peak_next_topic_config()
    local next_topic_id = self.next_topic_id

    if next_topic_id > #self.topic_configs then
        next_topic_id = 1
    end

    return self.topic_configs[next_topic_id]
end

function TopicPlayer:build_next_topic()
    -- Reset if the next_topic_id is out of bounds
    if self.next_topic_id > #self.topic_configs then
        self.next_topic_id = 1
    end

    local topic = self:create_topic(self.topic_configs[self.next_topic_id])

    self.next_topic_id = self.next_topic_id + 1
    
    return topic
end

function string:startswith(start)
    return self:sub(1, #start) == start
end

function TopicPlayer:create_topic(topic_config)
    local msg = topic_config.message

    if msg:startswith("!session-list") then
        return SessionListTopic:new(
            self,
            self.w, self.h, self.style,
            topic_config.duration,
            topic_config.heading,
            topic_config.message,
            topic_config.media
        )
    elseif msg:startswith("!session-brief") then
        return SessionBriefTopic:new(
            self,
            self.w, self.h, self.style,
            topic_config.duration,
            topic_config.heading,
            topic_config.message,
            topic_config.media
        )
    end

    -- Otherwise, make an InfoTopic
    return InfoTopic:new(
        self,
        self.w, self.h, self.style,
        topic_config.duration,
        topic_config.heading,
        topic_config.message,
        topic_config.media
    )
end

return TopicPlayer