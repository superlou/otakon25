gl.setup(1920, 1080)
-- require("test_runner")()
local Heading = require "heading"
require "color_util"
require "draw_util"
require "json_util"
require "glass"
local Ticker = require "ticker"
local Clock = require "clock"
local offset = require "offset"
local json = require "json"
local TopicPlayer = require "topic_player"
local tw = require "tween"
local ServiceIndicator = require "service_indicator"
local OctaviaPeek = require "octavia_peek"

local sidebar_bg = resource.load_image "img_sidebar_bg.png"
local main_bg = resource.load_image "img_main_bg3.png"
local inset_bg = resource.load_image "img_inset_bg.png"
local get_guidebook = resource.load_image "img_get_guidebook.png"
local ticker_left_crop = resource.load_image "img_ticker_left_crop.png"
local ticker_right_crop = resource.load_image "img_ticker_right_crop.png"
local ticker_right_triangle = resource.load_image "img_ticker_right_triangle.png"

local ticker_height = 116
local ticker = Ticker:new(0, HEIGHT - ticker_height, WIDTH, ticker_height)
local clock = Clock:new(200, 96)
local service_indicator = ServiceIndicator()

local style = require "style"
local topic_sidebar = TopicPlayer(640, 964, style["sidebar_style"])
local topic_main = TopicPlayer(1280, 964, style["main_style"])
local topic_inset = TopicPlayer(400, 300, style["inset_style"])

local octavia_peek = OctaviaPeek()

util.data_mapper {
    ["clock/update"] = function(data)
        data = json.decode(data)
        clock:update(data.hh_mm, data.am_pm, data.month, data.date)
    end;
    ["guidebook/update"] = function(data)
        data = json.decode(data)
        service_indicator:update(data.updating, data.checks, data.desc)
    end;
}

json_watch("config.json", function(config)
    ticker:set_speed(config.ticker_speed)
    ticker:set_msgs_from_config(config)
    topic_sidebar:set_topics_from_config(config["sidebar_topic_player"])
    topic_main:set_topics_from_config(config["main_topic_player"])
    topic_inset:set_topics_from_config(config["inset_topic_player"])
end)

local t = 0

function node.render()
    dt = 1 / 60
    t = t + dt
    tw:update(dt)

    gl.clear(1, 1, 1, 1)

    sidebar_bg:draw(0, 0, 640, 946)

    offset(0, 0, function()
        topic_sidebar:draw()
    end)

    main_bg:draw(640, 0, 1920, 964)

    offset(640, 0, function()
        topic_main:draw()
    end)

    draw_image_xywh(get_guidebook, 440, 730, 190, 209)

    if octavia_peek:is_behind() then
        octavia_peek:draw(dt)
    end

    ticker:draw()
    draw_image_xywh(ticker_left_crop, 0, 964, 470, 116)
    draw_image_xywh(ticker_right_crop, 1692, 964, 228, 116)

    offset(10, 730, function() 
        inset_bg:draw(0, 0, 420, 324)
    end)

    offset(20, 740, function()
        topic_inset:draw()
    end)


    offset(1710, 972, function()
        clock:draw()
    end)

    offset(10, 978, function()
        service_indicator:draw()
    end)

    if not octavia_peek:is_behind() then
        octavia_peek:draw(dt)
    end
end
