local class = require "middleclass"

local Topic = class("Topic")

local mask_shader = resource.create_shader[[
    uniform sampler2D mask;
    uniform sampler2D Texture;
    uniform float alpha;
    varying vec2 TexCoord;

    void main() {
        vec4 img = texture2D(Texture, TexCoord).rgba;
        img.a = texture2D(mask, TexCoord).a * alpha;
        gl_FragColor = img;
    }
]]

local Lifecycle = {
    RUNNING = 1,
    EXITING = 2,
    DONE = 3,
}

function Topic:initialize(player, w, h, style, duration)
    self.player = player
    self.w, self.h = w, h
    self.style = style
    self.duration = duration
    self.lifecycle = Lifecycle.RUNNING
end

function Topic:next_topic_has_bg()
    local next_topic_config = self.player:peak_next_topic_config()

    if next_topic_config == nil then
        return false
    end

    return next_topic_config.media.filename ~= "img_no_media.png" 
           and next_topic_config.media.asset_name
end

function Topic:set_done()
    self.lifecycle = Lifecycle.DONE
end

function Topic:set_exiting()
    self.lifecycle = Lifecycle.EXITING
end

function Topic:is_running()
    return self.lifecycle == Lifecycle.RUNNING
end

function Topic:is_exiting()
    return self.lifecycle == Lifecycle.EXITING
end

function Topic:is_done()
    return self.lifecycle == Lifecycle.DONE
end


function Topic:use_background_media(media, mask_filename)
    if media.filename ~= "img_no_media.png" and media.asset_name then
        self.background = resource.load_image(media.asset_name)
    end

    if mask_filename then
        self.mask = resource.load_image(mask_filename)
    end
end

function Topic:draw_background_media(alpha)
    if self.background then
        if self.mask then
            mask_shader:use {mask = self.mask, alpha = alpha}
        end
        self.background:draw(0, 0, self.w, self.h, alpha)
        if self.mask then
            mask_shader:deactivate()
        end
    end
end

return Topic