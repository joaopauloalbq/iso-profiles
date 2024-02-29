local naughty = require("naughty")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local upower = require(... .. ".upower")


local callback_enabled = true

local function getBrightnessIcon(brightness)
    if brightness == 100 then
        return "notification-display-brightness-full"
    elseif brightness >= 80 then
        return "notification-display-brightness-high"
    elseif brightness >= 40 then
        return "notification-display-brightness-medium"
    else
        return "notification-display-brightness-low"
    end
end    

function backlight(mode)
    awful.spawn.easy_async({ "sh", "-c", "light -" .. mode .. " 10 && light -G" }, function(brightness)
        naughty.notify ({
			replaces_id	= 2,
			text        = string.rep("■", math.ceil(brightness * 0.3)),
			icon        = getBrightnessIcon(tonumber(brightness)),
			ignore_suspend = true
		})
	end)
end

suitBATTERY = wibox.widget.imagebox()

suitBATTERY.tooltip = awful.tooltip{ objects = {suitBATTERY} }
suitBATTERY.bat = {["state"] = ""}
suitBATTERY:buttons( 
	gears.table.join(
		awful.button({ }, 4, function () backlight("A") end),
		awful.button({ }, 5, function () backlight("U") end)
	)
)

suitBATTERY.update = function()
	-- For some reason on_notify is called multiple times, this is a workaround to avoid that.
	if callback_enabled then
		callback_enabled = false
		local bat = upower:get_status()
		     	
     	if bat.state ~= suitBATTERY.bat.state then
     		if suitBATTERY.bat.state == "discharging" then
     			naughty.notify({title = "Energia", text = "Carregador conectado", icon = "battery-ac-adapter"})
     		end
     	end
		
		if bat.percentage <= 5 then
		    icon_name = "battery-000"
		elseif bat.percentage <= 10 then
		    icon_name = "battery-010"
		elseif bat.percentage <= 20 then
		    icon_name = "battery-020"
		elseif bat.percentage <= 30 then
		    icon_name = "battery-030"
		elseif bat.percentage <= 40 then
		    icon_name = "battery-040"
		elseif bat.percentage <= 50 then
		    icon_name = "battery-050"
		elseif bat.percentage <= 60 then
		    icon_name = "battery-060"
		elseif bat.percentage <= 70 then
		    icon_name = "battery-070"
		elseif bat.percentage <= 80 then
		    icon_name = "battery-080"
		elseif bat.percentage <= 90 then
		    icon_name = "battery-090"
		elseif bat.percentage <= 100 then
		    icon_name = "battery-100"
		end

		if bat.state ~= "discharging" then
		    icon_name = icon_name .. "-charging"
		end
		
		suitBATTERY:set_image(icon_path .. icon_name .. ".svg")
		suitBATTERY.tooltip:set_markup(bat.percentage .. "%" .. bat.estimated_time)
		suitBATTERY.bat = bat
		
        gears.timer.start_new (1, function() 
            callback_enabled = true
        end)
	end
end

-- Signal
upower:on_update(suitBATTERY.update)

suitBATTERY.update()

return suitBATTERY
