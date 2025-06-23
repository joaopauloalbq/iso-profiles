local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local dpi = require("beautiful.xresources").apply_dpi
local icon_theme = require("lgi").require("Gtk", "3.0").IconTheme.get_default()


local icon_dir

local function get_text_fg(is_muted)
    if is_muted then
        return "#676767"
    end
    
    return beautiful.notification_fg
end

local function get_icon_dir()
    local icon_info = icon_theme:lookup_icon("audio-volume-muted", dpi(24), 0)
    
    if icon_info then
        return string.match(icon_info:get_filename(), "(.*/)")
    end
    
    return ""
end

local function get_audio_icon(volume, is_muted)
    if is_muted then
        return "audio-volume-muted"
    elseif volume > 65 then
        return "audio-volume-high"
    elseif volume >= 35 then
        return "audio-volume-medium"
    else
        return "audio-volume-low"
    end
end

local suit_audio = wibox.widget{
    resize = false,
    widget = wibox.widget.imagebox
}

suit_audio:buttons(
    gears.table.join(
        awful.button({ }, 1, function() awful.spawn("pavucontrol") end),
        awful.button({ }, 2, function() suit_audio:toggle_mute() end),
        awful.button({ }, 4, function() suit_audio:inc_volume() end),
        awful.button({ }, 5, function() suit_audio:dec_volume() end)
    )
)

local suit_audio_tooltip = awful.tooltip{
    objects = {suit_audio}
}

function suit_audio:inc_volume()
	if self.volume < 100 then
        self.volume = self.volume + 5
    
        naughty.notify{
            replaces_id = self.notification_id,
            fg = get_text_fg(self.is_muted),
            text = string.rep("■", math.ceil(self.volume * 0.3)),
            icon = "notification-" .. get_audio_icon(self.volume, self.is_muted),
            ignore_suspend = true
        }

		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
    else
		awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ 100%", false)
        self.volume = 100
        
        naughty.notify{
            replaces_id = self.notification_id,
            fg = get_text_fg(self.is_muted),
            text = string.rep("■", math.ceil(self.volume * 0.3)),
            icon = "notification-" .. get_audio_icon(self.volume, self.is_muted),
            ignore_suspend = true
        }
	end
end

function suit_audio:dec_volume()
    self.volume = self.volume - 5
    
    naughty.notify{
        replaces_id = self.notification_id,
        fg = get_text_fg(self.is_muted),
        text = string.rep("■", math.ceil(self.volume * 0.3)),
        icon = "notification-" .. get_audio_icon(self.volume, self.is_muted),
        ignore_suspend = true
    }
    
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
end

function suit_audio:toggle_mute()
    self.is_muted = not self.is_muted
    
    naughty.notify{
        replaces_id = self.notification_id,
        fg = get_text_fg(self.is_muted),
        text = string.rep("■", math.ceil(self.volume * 0.3)),
        icon = "notification-" .. get_audio_icon(self.volume, self.is_muted),
        ignore_suspend = true
    }

    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
end

function suit_audio:update()
    awful.spawn.easy_async_with_shell("pactl get-sink-volume @DEFAULT_SINK@ && pactl get-sink-mute @DEFAULT_SINK@", function(output)
        self.volume = tonumber(output:match("Volume.- (%d+)%%"))
        self.is_muted = output:match("Mute: (%a+)") == "yes"

        suit_audio:set_image(icon_dir .. get_audio_icon(self.volume, self.is_muted) .. ".svg")
        suit_audio_tooltip:set_text(self.volume .. "%")
    end)
end

function suit_audio:on_update()
    awful.spawn.with_line_callback("pactl subscribe", {stdout = function(line_callback)
        if line_callback:find("Event 'change' on sink #") then
            self:update()
        end  
    end})
end

awesome.connect_signal("exit", function()
    awful.spawn.with_shell("killall pactl")
end)

function suit_audio:init()
    awful.spawn.easy_async_with_shell("pactl info", function(_, _, _, exit_code)
        if exit_code == 1 then
            self:init()
        else
            self.notification_id = naughty.get_next_notification_id()
            self:update()
            self:on_update()
        end
    end)
end


icon_dir = get_icon_dir()

suit_audio:init()


return suit_audio
