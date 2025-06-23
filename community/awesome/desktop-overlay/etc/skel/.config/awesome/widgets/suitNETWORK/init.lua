local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local nm = require(... .. '.nm')
local dpi = require("beautiful.xresources").apply_dpi
local icon_theme = require("lgi").require("Gtk", "3.0").IconTheme.get_default()


local function get_wifi_icon(strength)
    if strength <= 5 then
        return "network-wireless-connected-00"
    elseif strength <= 25 then
        return "network-wireless-connected-25"
    elseif strength <= 50 then
        return "network-wireless-connected-50"
    elseif strength <= 75 then
        return "network-wireless-connected-75"
    else
        return "network-wireless-connected-100"
    end
end

local function get_icon_dir()
    local icon_info = icon_theme:lookup_icon("battery-090", dpi(24), 0)
    if icon_info then
        return string.match(icon_info:get_filename(), "(.*/)")
    end
    return ""
end

local icon_dir = get_icon_dir()

local suit_network = wibox.widget{
    resize = false,
    widget = wibox.widget.imagebox
}

suit_network.tooltip = awful.tooltip{
    objects = {suit_network}
}

suit_network:buttons(
    gears.table.join(
        awful.button({ }, 1, function () awful.spawn([[networkmanager_dmenu -location 3]]) end),
        awful.button({ }, 3, function () awful.spawn(terminal .. " -e nmtui") end)
    )
)

suit_network.update = function()
    local ap = nm.wifi_device:get_active_access_point()

    if ap then
        local wifi = nm:get_ap_info(ap)
        
        suit_network:set_image(icon_dir .. get_wifi_icon(wifi.strength) .. ".svg")
        suit_network.tooltip:set_markup(wifi.ssid .. " " .. wifi.strength .. "%")
    else
        suit_network:set_image(icon_dir .. "network-wireless-disconnected" .. ".svg")
        suit_network.tooltip:set_markup("Wireless disconnected")
    end
end

-- Signal
nm:on_update(suit_network.update)

suit_network.update()

return suit_network
