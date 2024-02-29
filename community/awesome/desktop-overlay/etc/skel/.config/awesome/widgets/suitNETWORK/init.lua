local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty") 
local nm = require(... .. '.nm')


local callback_enabled = true

local suitNETWORK = wibox.widget.imagebox()
suitNETWORK.tooltip = awful.tooltip{objects = {suitNETWORK}}
suitNETWORK:buttons( gears.table.join(
                        awful.button({ }, 1, function () awful.spawn([[networkmanager_dmenu -location 3]]) end),
                        awful.button({ }, 3, function () awful.spawn(terminal .. " -e nmtui") end)))

suitNETWORK.update = function()
    -- For some reason on_notify is called multiple times, this is a workaround to avoid that.
	-- if os.time() ~= last_time then
	if callback_enabled then
	    callback_enabled = false
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
                            
        gears.timer.start_new (1, function() 
            callback_enabled = true
        end)
    end
    
    -- last_time = os.time()
end

-- Signal
nm:on_update(suitNETWORK.update)

suitNETWORK.update()

return suitNETWORK
