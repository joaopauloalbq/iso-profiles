local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

function getBrightnessIcon(brightness)
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
suitBATTERY.tooltip = awful.tooltip{objects = {suitBATTERY}}
suitBATTERY:buttons( gears.table.join(
                        awful.button({ }, 4, function () backlight("A") end),
                        awful.button({ }, 5, function () backlight("U") end)))

gears.timer {
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = function()
        awful.spawn.easy_async(
            {"sh", "-c", "acpi -b"},
            function(stdout)
                local icon_name = "battery"
                local status, level, estimated_time = string.match(stdout, '.+: ([%a%s]+), (%d?%d?%d)%%(.*)')
                local level = tonumber(level)
                
                if level <= 5 then
                    icon_name = icon_name .. "-000"
                elseif level <= 10 then
                    icon_name = icon_name .. "-010"
                elseif level <= 20 then
                    icon_name = icon_name .. "-020"
                elseif level <= 30 then
                    icon_name = icon_name .. "-030"
                elseif level <= 40 then
                    icon_name = icon_name .. "-040"
                elseif level <= 50 then
                    icon_name = icon_name .. "-050"
                elseif level <= 60 then
                    icon_name = icon_name .. "-060"
                elseif level <= 70 then
                    icon_name = icon_name .. "-070"
                elseif level <= 80 then
                    icon_name = icon_name .. "-080"
                elseif level <= 90 then
                    icon_name = icon_name .. "-090"
                elseif level <= 100 then
                    icon_name = icon_name .. "-100"
                end
        
                if status ~= "Discharging" then
                    icon_name = icon_name .. "-charging"
                end
        
                suitBATTERY:set_image(icon_path .. icon_name .. ".svg")
                suitBATTERY.tooltip:set_markup(level .. "%" .. estimated_time:sub(1,-2))
            end
        )
    end
}

return suitBATTERY
