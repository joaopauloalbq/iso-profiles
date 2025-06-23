local gears = require("gears")
local awful = require("awful")
-------------------------------------------------------------------------------------------------------------------
return gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        local margin = 6
        local m = mouse.coords()
        if (m.x <= c.x + margin or m.y <= c.y + margin or m.x >= c.x + c.width - margin or m.y >= c.y + c.height - margin) then
            awful.mouse.client.resize(c)
        end
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)