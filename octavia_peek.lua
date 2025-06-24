require "draw_util"
local class = require "middleclass"
local OctaviaPeek = class("OctaviaPeek")

local octavias = {
    {
        image = resource.load_image("img_octavia_angry.png"),
        w = 112, h = 99, bottom = 84,
    },
    {
        image = resource.load_image("img_octavia_badge.png"),
        w = 162, h = 139, bottom = 105,
    },    
    {
        image = resource.load_image("img_octavia_cosplay.png"),
        w = 140, h = 120, bottom = 95,
    },
    {
        image = resource.load_image("img_octavia_gaming.png"),
        w = 153, h = 131, bottom = 100,
    },
    {
        image = resource.load_image("img_octavia_love.png"),
        w = 116, h = 102, bottom = 88,
    },
    {
        image = resource.load_image("img_octavia_megaphone.png"),
        w = 153, h = 131, bottom = 102,
    },
    {
        image = resource.load_image("img_octavia_mic.png"),
        w = 154, h = 132, bottom = 101,
    },
    {
        image = resource.load_image("img_octavia_octavia.png"),
        w = 159, h = 137, bottom = 104,
    },
    {
        image = resource.load_image("img_octavia_panic_watch.png"),
        w = 146, h = 125, bottom = 100,
    },
    {
        image = resource.load_image("img_octavia_reading.png"),
        w = 131, h = 116, bottom = 93,
    },
    {
        image = resource.load_image("img_octavia_rps.png"),
        w = 160, h = 137, bottom = 103,
    },
    {
        image = resource.load_image("img_octavia_shopping.png"),
        w = 130, h = 108, bottom = 89,
    },
    {
        image = resource.load_image("img_octavia_sign.png"),
        w = 157, h = 135, bottom = 107,
    },
    {
        image = resource.load_image("img_octavia_surprise.png"),
        w = 110, h = 98, bottom = 80,
    },
    {
        image = resource.load_image("img_octavia_tentacle_guns.png"),
        w = 119, h = 105, bottom = 90,
    },
    {
        image = resource.load_image("img_octavia_tux.png"),
        w = 167, h = 143, bottom = 111,
    },
    {
        image = resource.load_image("img_octavia_wave.png"),
        w = 120, h = 106, bottom = 93,
    },
    {
        image = resource.load_image("img_octavia_wink.png"),
        w = 120, h = 106, bottom = 91,
    },
    {
        image = resource.load_image("img_octavia_writing.png"),
        w = 159, h = 136, bottom = 104,
    }
}

local State = {
    HIDDEN = 0,
    APPEARING = 1,
    VISIBLE = 2,
    HIDING = 3, 
}

function OctaviaPeek:initialize()
    self._is_behind = true
    self.state = State.HIDDEN
    self.x = 653
    self.y = 1200
    self.mirror = false
    self.y_target = 960

    self.octavia_id = 19
    self.hide_timer = 10

    self.flips = 0
    self.flip_timer = 0
end

function OctaviaPeek:is_behind()
    return self._is_behind
end

function OctaviaPeek:draw_octavia()
    draw_image_xywh(
        octavias[self.octavia_id].image,
        self.x, self.y,
        octavias[self.octavia_id].w, octavias[self.octavia_id].h,
        self.mirror
    )
end

function OctaviaPeek:draw(dt)
    if self.state == State.HIDDEN then
        self.hide_timer = self.hide_timer - dt
        self._is_behind = true

        if self.hide_timer < 0 then
            self.state = State.APPEARING

            if math.random(100) < 20 then
                -- Over the ad insert
                self.x = math.random(10, 280)
                self.y_target = 724
            else
                -- Over the ticker
                self.x = math.random(462, 1770)
                self.y_target = 960
            end

            self.octavia_id = math.random(#octavias)
        end
    elseif self.state == State.APPEARING then
        self._is_behind = true
        self.y = self.y - 140 * dt
        self:draw_octavia()

        if self.y < (self.y_target - octavias[self.octavia_id].bottom) then
            self.state = State.VISIBLE
            self.flips = math.floor(math.random() * 5 + 2)
            self.flip_timer = math.random() * 0.5 + 0.1
        end
    elseif self.state == State.VISIBLE then
        self._is_behind = false
        self:draw_octavia()

        self.flip_timer = self.flip_timer - dt

        if self.flip_timer < 0 and self.flips > 0 then
            self.flips = self.flips - 1
            self.flip_timer = math.random() * 0.5 + 0.5
            self.mirror = not self.mirror
        end

        if self.flip_timer <= 0 then
            self.state = State.HIDING
        end
    elseif self.state == State.HIDING then
        self._is_behind = true
        self.y = self.y + 140 * dt
        self:draw_octavia()
        if self.y > 1200 then
            self.state = State.HIDDEN
            self.hide_timer = math.random(60, 120)
        end
    end
end

return OctaviaPeek