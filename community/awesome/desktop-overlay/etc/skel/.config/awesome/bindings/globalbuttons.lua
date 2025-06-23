local gears = require("gears")
local awful = require("awful")
-------------------------------------------------------------------------------------------------------------------
local myexitmenu = {
    { "Shutdown", "systemctl poweroff" },
    { "Suspend", "systemctl suspend" },
    { "Hibernate", "systemctl hibernate" },
    { "Reboot", "systemctl reboot" },
    { "Restart", awesome.restart },
    { "Logout", function() awesome.quit() end },
}

local mydesktopmenu = awful.menu{
    items = {
        { "Hotkeys", function() return false, require("awful.hotkeys_popup").show_help end },
        { "Settings", function() suit_settings:toggle() end},
        { "Exit", myexitmenu }
    }
}
-------------------------------------------------------------------------------------------------------------------
root.buttons(gears.table.join(
    awful.button({ }, 1, function ()
        mydesktopmenu:hide()
        awesome.emit_signal("button::press")
    end),
    awful.button({ }, 3, function () mydesktopmenu:toggle() end)
))
-------------------------------------------------------------------------------------------------------------------
