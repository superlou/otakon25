local class = require "middleclass"

local Tween = class("Tween")
local Tweener = class("Tweener")

local dummy = {}

function Tweener:initialize()
    self.tweens = {}
end

function Tweener:tween(target_obj, target_property, start_val, finish_val, duration)
    local tween = Tween:new(target_obj, target_property, start_val, finish_val, duration)
    table.insert(self.tweens, tween)
    return tween
end

function Tweener:timer(delay)
    local tween = Tween:new(dummy, "_", 0, 0, 0):delay(delay)
    table.insert(self.tweens, tween)
    return tween
end

function Tweener:update(dt)
    for i, tween in ipairs(self.tweens) do
        tween:update(dt)
    end

    -- Safely remove done tweens by iterating backwards
    for i = #self.tweens, 1, -1 do
        if self.tweens[i]:is_done() then
            table.remove(self.tweens, i)
        end
    end
end

local tweener = Tweener:new()

function Tween:initialize(target_obj, target_property, start_val, finish_val, duration)
    self.target_obj = target_obj
    self.target_property = target_property
    self.t = 0
    self.t0 = 0
    self.t1 = duration
    self.v0 = start_val
    self.v1 = finish_val
    self.original_delay = 0
    self.remaining_delay = 0
    self.done = false
    self.done_fn = function() end
end

function Tween:delay(delay)
    self.original_delay = delay
    self.remaining_delay = delay
    return self
end

function Tween:on_done(fn)
    self.done_fn = fn
    return self
end

function Tween:then_after(delay, fn)
    local tween = tweener:timer(self.original_delay + delay)
    tween:on_done(fn)
    return tween
end

function Tween:update(dt)
    if self.remaining_delay > 0 then
        self.remaining_delay = self.remaining_delay - dt
        return
    end

    self.t = self.t + dt

    local fraction = (self.t - self.t0) / (self.t1 - self.t0)
    if fraction > 1 then fraction = 1 end

    local v = (1 - fraction) * self.v0 + fraction * self.v1
    self.target_obj[self.target_property] = v

    if fraction == 1 then
        self.done = true
        self.done_fn()
    end
end

function Tween:is_done()
    return self.done
end

return tweener