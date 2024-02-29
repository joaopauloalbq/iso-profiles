local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")


local callback_enabled = true

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
    callback_enabled = false

    awful.spawn.easy_async({ "sh", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle; pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@" }, function(output)
        local vol = tonumber(output:match("Volume: front.- (%d+)%%"))
        local muted = output:match("Mute: (%a+)") == "yes"
        
        local audioIcon = getAudioIcon(vol, muted)
        self:set_image(icon_path .. audioIcon .. ".svg")
        
        naughty.notify ({
            replaces_id     = self.notification_id,
            fg              = getTextFG(muted),
            text            = string.rep("■", math.ceil(vol * 0.3)),
            icon            = "notification-" .. audioIcon,
            ignore_suspend  = true
        })
        
        callback_enabled = true
    end)
end

function suitAUDIO:volume(mode)
    callback_enabled = false
    awful.spawn.easy_async({ "sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " .. mode .. "5% ; pactl get-sink-volume @DEFAULT_SINK@ ; pactl get-sink-mute @DEFAULT_SINK@" }, function(output)
        local vol = tonumber(output:match("Volume: front.- (%d+)%%"))
        local muted = output:match("Mute: (%a+)") == "yes"
        
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
        
        callback_enabled = true
	end)
end


function suitAUDIO:update(mode)
    awful.spawn.easy_async({ "sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@" }, function(output)
        local vol = tonumber(output:match("Volume: front.- (%d+)%%"))
        local muted = output:match("Mute: (%a+)") == "yes"
        
        local audioIcon = getAudioIcon(vol, muted)
        self:set_image(icon_path .. audioIcon .. ".svg")
        self.tooltip:set_markup(vol .. "%")
	end)
end
    
function suitAUDIO:init()
    awful.spawn.easy_async({ "sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@" }, function(output, _, _, exit_code)
        if exit_code == 1 then
            self:init()
        else
            local vol = tonumber(output:match("Volume: front.- (%d+)%%"))
            local muted = output:match("Mute: (%a+)") == "yes"
            
            local audioIcon = getAudioIcon(vol, muted)
            self:set_image(icon_path .. getAudioIcon(vol, muted) .. ".svg")
            self.tooltip:set_markup(vol .. "%")
            self.notification_id = naughty.get_next_notification_id() -- reserve id 1 to volume notification
            
            --Callback            
            awful.spawn.with_line_callback({"sh", "-c", "killall pactl; pactl subscribe"}, {
                stdout = function()
                    if callback_enabled then
                        callback_enabled = false
                        
                        suitAUDIO:update()
                        
                        gears.timer.start_new (1, function() 
                            callback_enabled = true
                        end)
                    end
                end
            })
        end
    end)
    
end


suitAUDIO:init()

return suitAUDIO
