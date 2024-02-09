local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")

local function getAudioIcon(vol, muted)
    if muted then
        return "audio-volume-muted"
    elseif vol > 65 then
        return "audio-volume-high"
    elseif vol >= 35 then
        return "audio-volume-medium"
    else
        return "audio-volume-low"
    end
end

local function getTextFG(muted)
    if muted then
        return "#676767"
    end
    return beautiful.notification_fg
end

local suitAUDIO = wibox.widget.imagebox()
suitAUDIO.tooltip = awful.tooltip{objects = {suitAUDIO}}
suitAUDIO:buttons( 
    gears.table.join(
        awful.button({ }, 1, function () awful.spawn([[pavucontrol]]) end),
        awful.button({ }, 2, function () suitAUDIO:mute() end),
        awful.button({ }, 4, function () suitAUDIO:volume("+") end),
        awful.button({ }, 5, function () suitAUDIO:volume("-") end)
    )
)

function suitAUDIO:mute()
    awful.spawn.easy_async({ "sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && wpctl get-volume @DEFAULT_AUDIO_SINK@" }, function(output)
        local vol = string.match(output, "%d%.%d%d")
        local muted = string.find(output, "MUTED")
        
        vol = tonumber(vol) * 100
        local audioIcon = getAudioIcon(vol, muted)
        self:set_image(icon_path .. audioIcon .. ".svg")
        
        naughty.notify ({
            replaces_id     = self.notification_id,
            fg              = getTextFG(muted),
            text            = string.rep("■", math.ceil(vol * 0.3)),
            icon            = "notification-" .. audioIcon,
            ignore_suspend  = true
        })
    end)
end

function suitAUDIO:volume(mode)
    awful.spawn.easy_async({ "sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%" .. mode .. " && wpctl get-volume @DEFAULT_AUDIO_SINK@" }, function(output)
        local vol = string.match(output, "%d%.%d%d")
        local muted = string.find(output, "MUTED")
        
        vol = tonumber(vol) * 100
        local audioIcon = getAudioIcon(vol, muted)
        self:set_image(icon_path .. audioIcon .. ".svg")
        self.tooltip:set_markup(vol .. "%")
        
        naughty.notify ({
            replaces_id	    = self.notification_id,
            fg              = getTextFG(muted),
            text            = string.rep("■", math.ceil(vol * 0.3)),
            icon            = "notification-" .. audioIcon,
            ignore_suspend  = true
        })
	end)
end

function suitAUDIO:init()
    awful.spawn.easy_async({ "sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@" }, function(output, _, _, exit_code)
        if output == "" then
            self:init()
        else
            local vol = string.match(output, "%d%.%d%d")
            local muted = string.find(output, "MUTED")
            
            vol = tonumber(vol) * 100
            local audioIcon = getAudioIcon(vol, muted)
            self:set_image(icon_path .. getAudioIcon(vol, muted) .. ".svg")
            self.tooltip:set_markup(vol .. "%")
            self.notification_id = naughty.get_next_notification_id() -- reserve id 1 to volume notification
        end
    end)
end

suitAUDIO:init()

return suitAUDIO
