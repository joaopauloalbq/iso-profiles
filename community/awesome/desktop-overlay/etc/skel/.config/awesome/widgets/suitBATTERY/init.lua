local naughty = require("naughty")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local upower = require(... .. ".upower")
local dpi = require("beautiful.xresources").apply_dpi
local icon_theme = require("lgi").require("Gtk", "3.0").IconTheme.get_default()


-- TODO
-- [] Adicionar modo economizar energia


local callback_enabled = true
local backlight_notification_id = naughty.get_next_notification_id() -- reserve id to brightness notification

local function get_icon_dir()
    local icon_info = icon_theme:lookup_icon("battery-090", dpi(24), 0)
    if icon_info then
        return string.match(icon_info:get_filename(), "(.*/)")
    end
    return ""
end

local icon_dir = get_icon_dir()

local function get_brightness_icon(level)
    if level == 100 then
        return "notification-display-brightness-full"
    elseif level >= 80 then
        return "notification-display-brightness-high"
    elseif level >= 40 then
        return "notification-display-brightness-medium"
    else
        return "notification-display-brightness-low"
    end
end

function backlight(mode)
    awful.spawn.easy_async({ "sh", "-c", "light -" .. mode .. " 10 ; light -G" }, function(brightness)
        naughty.notify ({
			replaces_id	= backlight_notification_id,
			text        = string.rep("■", math.ceil(brightness * 0.3)),
			icon        = get_brightness_icon(tonumber(brightness)),
			ignore_suspend = true
		})
	end)
end

local suit_battery = wibox.widget{
	{
		id = "icon",
		widget = wibox.widget.imagebox
	},
	{
		id = "text",
		visible = false,
		widget = wibox.widget.textbox
	},
	visible = upower.device.is_present,
	layout = wibox.layout.fixed.horizontal,
}

suit_battery.tooltip = awful.tooltip{
	objects = {suit_battery}
}

suit_battery.previous_state = "unknown"
suit_battery.previous_warning_level = "none"

suit_battery:buttons(
	gears.table.join(
		awful.button({ }, 1, function () suit_battery.text.visible = not suit_battery.text.visible end),
		awful.button({ }, 4, function () backlight("A") end),
		awful.button({ }, 5, function () backlight("U") end)
	)
)

suit_battery.update = function()
	-- For some reason on_notify is called multiple times, this is a workaround to avoid that.
	if callback_enabled then
		callback_enabled = false
		local device = upower:get_status()

		if suit_battery.previous_warning_level ~= device.warning_level then
			if device.warning_level == "low" then
				naughty.notify({title = "Energia", text = "Nível de bateria baixa", icon = "notification-battery-low"})
			elseif device.warning_level == "critical" then
				awful.spawn("systemctl suspend-then-hibernate")
			end
		end
		     	
     	if suit_battery.previous_state ~= device.state then
			if device.state == "discharging" then
				naughty.notify({title = "Energia", text = "Carregador desconectado", icon = "battery-ac-adapter"})
			end
     	end
		
		local icon_name
		if device.percentage <= 5 then
		    icon_name = "battery-000"
		elseif device.percentage <= 10 then
		    icon_name = "battery-010"
		elseif device.percentage <= 20 then
		    icon_name = "battery-020"
		elseif device.percentage <= 30 then
		    icon_name = "battery-030"
		elseif device.percentage <= 40 then
		    icon_name = "battery-040"
		elseif device.percentage <= 50 then
		    icon_name = "battery-050"
		elseif device.percentage <= 60 then
		    icon_name = "battery-060"
		elseif device.percentage <= 70 then
		    icon_name = "battery-070"
		elseif device.percentage <= 80 then
		    icon_name = "battery-080"
		elseif device.percentage <= 90 then
		    icon_name = "battery-090"
		elseif device.percentage <= 100 then
		    icon_name = "battery-100"
		end

		if device.state ~= "discharging" then
		    icon_name = icon_name .. "-charging"
		end
		
		suit_battery.icon:set_image(icon_dir .. icon_name .. ".svg")
		suit_battery.text:set_text(device.percentage .. "%")
		suit_battery.tooltip:set_text(device.percentage .. "%" .. device.estimated_time)
		suit_battery.previous_state = device.state
		suit_battery.previous_warning_level = device.warning_level
		
        gears.timer.start_new (1, function() callback_enabled = true end)
	end
end


-- Signal
upower:on_update(suit_battery.update)

suit_battery.update()

return suit_battery
