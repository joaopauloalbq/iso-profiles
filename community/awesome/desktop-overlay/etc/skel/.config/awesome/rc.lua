-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- Widget and layout library
local wibox = require("wibox")
-- Notification library
local naughty = require("naughty")
-- Overview
local revelation = require("revelation")
-- Theme handling library
beautiful = require("beautiful")


require("awful.autofocus")
require("error")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- require("awful.hotkeys_popup.keys")

awful.layout.layouts = require("layout")

-- {{{ Variable definitions
local dpi = beautiful.xresources.apply_dpi
awful.util.shell = "sh"
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/nord-pink/theme.lua")
revelation.init({charorder = "asdfqwergtbvcxz"})

-- This is used later as the default terminal and editor to run.
terminal = os.getenv("TERMINAL")
editor = os.getenv("EDITOR")

-- Notification definitions
naughty.config.defaults.border_width = beautiful.notification_border_width
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.padding = dpi(14)
naughty.config.spacing = dpi(6)
naughty.config.icon_formats = {"svg"}
naughty.config.icon_dirs = {"/usr/share/icons/Papirus-Dark/48x48/status/", "/usr/share/icons/Papirus-Dark/48x48/categories/"}
-- naughty.config.icon_dirs = {"/usr/share/icons/Papirus-Dark/48x48/status/", "/usr/share/icons/Papirus-Dark/48x48/categories/"}

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"
-- }}}

-- {{{ Menu                         
suitSettingsLauncher = awful.widget.launcher({ image = "/usr/share/icons/Papirus-Dark/24x24/panel/fcitx-mozc-properties.svg", command = [[rofi -modi suit-settings -show suit-settings -theme settings]] })
-- }}}

-- {{{ Wibar
suit_audio    = require("widgets.suitAUDIO")
suit_network  = require("widgets.suitNETWORK")
suit_battery  = require("widgets.suitBATTERY")
-- suit_menu     = require("widgets.dmenu")
suit_launcher = require("widgets.suitLAUNCHER")
suit_settings = require("widgets.suitSETTINGS")
suit_calendar = require("widgets.suitCALENDAR")

mytextclock = wibox.widget.textclock(" %a %d, %H:%M ")
mytextclock:buttons(gears.table.join(
    -- awful.button({ }, 1, function () awful.spawn([[gsimplecal]], false) end),
    awful.button({ }, 1, function () suit_calendar:toggle() end)
))

suit_tray = wibox.widget.systray(true)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ }, 2, function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end),
    awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                {raise = true}
            )
        end
    end),
    awful.button({ }, 2, function (c)
        c:kill()
    end),
    awful.button({ }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end),
    awful.button({ }, 4, function ()
        awful.client.swap.byidx( 1)
    end),
    awful.button({ }, 5, function ()
        awful.client.swap.byidx(-1)
    end)
)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    awful.spawn([[nitrogen --restore]], false)

    -- Each screen has its own tag table.
    awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 " }, s, awful.layout.layouts[1])
    
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 2, function () awful.layout.set(awful.layout.layouts[1]) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        -- style   = { shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,6) end, },
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
       	widget_template = {
            {
                {
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 3,
                        widget  = wibox.container.margin,
                    },
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 1,
                right = 3,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
		},
    }
    
    -- Create the wibox
    s.suitBAR = awful.wibar{ screen = s, position = "top", height = 24 } -- opacity = 0.90
 	-- os.setlocale(os.getenv("LANG"))
    
    -- Add widgets to the wibox
    s.suitBAR:setup {
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            suit_launcher,
            s.mytaglist,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = beautiful.systray_icon_spacing,
            
            suit_tray,
            suit_network,
            suit_audio,
            suit_battery,
            suitSettingsLauncher,
            mytextclock,
            s.mylayoutbox,
        },
        layout = wibox.layout.align.horizontal,
    }
end)
-- }}}

-- Mouse bindings
require("bindings.globalbuttons")

-- Key bindings
require("bindings.globalkeys")

-- Signals
require("signals")

-- Rules
require("rules")

-- 
require("autostart")

collectgarbage("setpause", 150)

-------------------------------------------
local function new_row(text)
    return wibox.widget{
        {
            {
                text = text,
                widget = wibox.widget.textbox
            },
            margins = dpi(9),
            widget  = wibox.container.margin
        },
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }
end

leak = awful.popup{
    widget = wibox.layout.fixed.vertical,
    ontop = true,
    visible = false,
    hide_on_right_click = true,
    placement = awful.placement.centered
}

leak:connect_signal("property::visible", function(self)
    if self.visible then
        for i = 1, 4 do
            self.widget:add(new_row(tostring(i)))
        end
        
        i = 5
        gears.timer.start_new(0.01, function()
            self.widget:remove(1)
            self.widget:add(new_row(tostring(i)))
            
            if i == 2000 then
                return false
            end

            i = i + 1
            return true
        end)
    else
        self.widget:reset()
        collectgarbage("collect")
    end
end)

-- gears.timer.start_new(0.5, function()
--     leak.visible = true
--     return false
-- end)
-------------------------------------------