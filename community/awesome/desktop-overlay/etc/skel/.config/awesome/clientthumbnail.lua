--[[-- Widget to show client thumbnail.

This module only work when the client is on the screen.
Otherwise it will use the cached image surface of the client.

@see https://www.reddit.com/r/awesomewm/comments/akiqz2/any_way_to_get_a_image_preview_of_a_running_window/
--]]
local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

local module = {}

-- Cache the surface of clients
local surface_cache = setmetatable({}, { __mode = "k" })
function module.cache_surface(c)
    local s = gears.surface(c.content)
    s = gears.surface.duplicate_surface(s)
    surface_cache[c] = s
end

-- cache the surface when minimizing or unfocus (switch to other tags)
client.connect_signal("property::minimized", function(c)
    module.cache_surface(c)
end)
client.connect_signal("unfocus", function(c)
    if not c then return end
    module.cache_surface(c)
end)

--- Set the widget client
function module:set_client(c)
    self._private.client[1] = c
    self:emit_signal("widget::redraw_needed")
end

--- Get the widget client
function module:get_client()
    return self._private.client[1]
end

--- Draw the widget, standard AwesomeWM method
function module:draw(context, cr, width, height)
    -- get and check set client
    local c = self._private.client[1]
    if not c then
        cr:move_to(0, 0)
        cr:line_to(width, height)
        cr:move_to(0, height)
        cr:line_to(width, 0)
        cr:stroke()
        return
    end

    -- check if the client is on the screen
    -- if not use the cached surface or the icon
    -- (if the client is not cached),
    -- otherwise use the current surface
    local onscreen = false
    local scr = awful.screen.focused()
    local s
    for _, c_ in ipairs(scr.clients) do
        if c_ == c and not c.minimized then
            onscreen = true
        end
    end
    if onscreen then
        s = gears.surface(c.content)
    else
        s = surface_cache[c] or gears.surface(c.icon)
    end

    -- rescale the client surface and center it inside the widget
    local swidth, sheight = gears.surface.get_size(s)
    local scale = math.min(width / swidth, height / sheight)
    local w, h = swidth * scale, sheight * scale
    local dx, dy = (width - w) / 2, (height - h) / 2
    cr:translate(dx, dy)
    cr:scale(scale, scale)
    cr:set_source_surface(s)
    cr:paint()
end

--- Fit the widget, standard AwesomeWM method
function module:fit(context, width, height)
    local m = math.min(width, height)
    return m, m
end

--- Create a new client thumbnail widget
function module.new(c)
    local config = { enable_properties = true }
    local ret = wibox.widget.base.make_widget(nil, nil, config)
    gears.table.crush(ret, module, true)
    ret._private.client = setmetatable({ c }, { __mode = "v" })
    return ret
end

return setmetatable(module, { __call = function(_, ...) return module.new(...) end })
