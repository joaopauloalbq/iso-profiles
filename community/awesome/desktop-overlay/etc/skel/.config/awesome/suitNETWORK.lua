local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local nm = require("nm")

local suitNETWORK = wibox.widget.imagebox()
suitNETWORK.tooltip = awful.tooltip{objects = {suitNETWORK}}
suitNETWORK:buttons( gears.table.join(
                        awful.button({ }, 1, function () awful.spawn([[networkmanager_dmenu -location 3]]) end),
                        awful.button({ }, 3, function () awful.spawn(terminal .. " -e nmtui") end)))

gears.timer {
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = function()
        ap = nm.wifi_device:get_active_access_point()

        if ap then
            wifi = nm:get_ap_info(ap)
            if wifi.strength <= 5 then
                icon_name = "network-wireless-connected-00"
            elseif wifi.strength <= 25 then
                icon_name = "network-wireless-connected-25"
            elseif wifi.strength <= 50 then
                icon_name = "network-wireless-connected-50"
            elseif wifi.strength <= 75 then
                icon_name = "network-wireless-connected-75"
            elseif wifi.strength <= 100 then
                icon_name = "network-wireless-connected-100"
            end
            
            suitNETWORK:set_image(icon_path .. icon_name .. ".svg")
            suitNETWORK.tooltip:set_markup(wifi.ssid .. " " .. wifi.strength .. "%")
        else
            suitNETWORK:set_image(icon_path .. "network-wireless-disconnected" .. ".svg")
            suitNETWORK.tooltip:set_markup("Wireless disconnected")
        end
    end
}

return suitNETWORK
