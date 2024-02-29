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
icon_path = "/usr/share/icons/Papirus-Dark/24x24/panel/"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"
-- }}}

-- {{{ Menu
-- To add the menu to a widget:
myexitmenu = {
    { "Shutdown", "systemctl poweroff" }, 
    { "Suspend", "systemctl suspend" },
    { "Hibernate", "systemctl hibernate" },
    { "Restart", "systemctl reboot" },
    { "Logout", function() awesome.quit() end },
}

mydesktopmenu = awful.menu({ items = { { "Hotkeys", function() return false, hotkeys_popup.show_help end },
                                       { "Wallpaper", function() mouse.coords({x=awful.screen.focused().geometry.width - 200, y=mouse.coords().y}) awful.spawn([[rofi -modi suit-wallpaper -show suit-wallpaper -theme wallpaper]]) end},
                                       { "Settings", function() mouse.coords({x=awful.screen.focused().geometry.width - 200, y=mouse.coords().y}) awful.spawn([[rofi -modi suit-settings -show suit-settings -theme settings]]) end},
                                       { "Exit", myexitmenu }
                                    }})
                                    
mylauncher = awful.widget.launcher({ image = ".config/awesome/themes/nord-pink/suit-logo.png", command = [[rofi -modi drun -show drun -theme grid -location 1 -selected-row 0 -yoffset 37 -xoffset 13]] })

-- suitSettingsLauncher = awful.widget.launcher({ image = icon_theme:lookup_icon("fcitx-mozc-properties", dpi(24), 0):get_filename(), command = 'rofi -modi suit-settings -show suit-settings -theme settings' })
suitSettingsLauncher = awful.widget.launcher({ image = "/usr/share/icons/Papirus-Dark/24x24/panel/fcitx-mozc-properties.svg", command = [[rofi -modi suit-settings -show suit-settings -theme settings]] })
-- }}}

-- {{{ Wibar
mytextclock = wibox.widget.textclock(" %a %d, %H:%M ")
mytextclock:buttons( gears.table.join(
                        awful.button({ }, 1, function () awful.spawn([[gsimplecal]], false) end),
                        awful.button({ }, 4, function () awful.spawn([[gsimplecal next_month]], false) end),
                        awful.button({ }, 5, function () awful.spawn([[gsimplecal prev_month]], false) end))
                    )

suitTRAY = wibox.widget.systray()
suitTRAY:set_reverse(true)
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
                                              -- awful.menu.client_list({ theme = { width = 300 } })
                                              c:emit_signal("request::activate", "mouse_click", {raise = true})
                                              awful.mouse.client.resize(c)
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.swap.byidx( 1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.swap.byidx(-1)
                                          end))

local function set_wallpaper()
    awful.spawn([[nitrogen --restore]], false)
end

local function run_once(exeCmd, exeArgs, exeBefore)
	exeArgs = exeArgs or ''
	exeBefore = (exeBefore and exeBefore .. ' &&') or ''
    
    awful.spawn(string.format([[sh -c "pidof %s || %s %s %s"]], exeCmd, exeBefore, exeCmd, exeArgs), false)
end

-- Toggle titlebar on or off depending on <condition>. Creates titlebar if it doesn't exist
local function setTitlebar(client, condition)
    if condition then
        awful.titlebar.show(client)
    else 
        awful.titlebar.hide(client)
    end
end

-- local function getBrightnessIcon(brightness)
--     if brightness == 100 then
--         return "notification-display-brightness-full"
--     elseif brightness >= 80 then
--         return "notification-display-brightness-high"
--     elseif brightness >= 40 then
--         return "notification-display-brightness-medium"
--     else
--         return "notification-display-brightness-low"
--     end
-- end    
-- 
-- function backlight(mode)
--     awful.spawn.easy_async({ "sh", "-c", "light -" .. mode .. " 10 && light -G" }, function(brightness)
--         naughty.notify ({
-- 			replaces_id	= 2,
-- 			text        = string.rep("■", math.ceil(brightness * 0.3)),
-- 			icon        = getBrightnessIcon(tonumber(brightness)),
-- 			ignore_suspend = true
-- 		})
-- 	end)
-- end

suitAUDIO = require("widgets.suitAUDIO")
suitNETWORK = require("widgets.suitNETWORK")
suitBATTERY = require("widgets.suitBATTERY")

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper()

    -- Each screen has its own tag table.
    awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 " }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 2, function () awful.layout.set(awful.layout.layouts[1]) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
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
    s.suitBAR = awful.wibar({ screen = s, position = "top", height = 24 }) -- opacity = 0.90
 	-- os.setlocale(os.getenv("LANG"))
    
    -- Add widgets to the wibox
    s.suitBAR:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
            s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = beautiful.systray_icon_spacing,
            
            suitTRAY,
            suitNETWORK,
            suitAUDIO,
            suitBATTERY,
            suitSettingsLauncher,
            -- awful.widget.keyboardlayout(),
            -- wibox.widget.textclock(" %a %d, %H:%M "),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 1, function () mydesktopmenu:hide() end),
    awful.button({ }, 3, function () mydesktopmenu:toggle() end)
    -- awful.button({ }, 5, awful.tag.viewprev),
    -- awful.button({ }, 4, awful.tag.viewnext),
))
-- }}}

-- {{{ Key bindings
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    -- awful.button({ }, 2, function (c)
        -- c:emit_signal("request::activate", "mouse_click", {raise = true})
        -- awful.mouse.client.resize(c)
    -- end),
    awful.button({ }, 3, function (c)
        local m = mouse.coords()
        if (m.x <= c.x + 8 or m.y <= c.y + 8 or m.x >= c.x + c.width - 8 or m.y >= c.y + c.height - 8) then
            awful.mouse.client.resize(c)
        end
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "_NET_WM_STATE_FULLSCREEN_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(require("keybinds.globalkeys"))
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)    
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end
    
    if c.maximized then c.border_width = 0 else c.border_width = beautiful.border_width end
    
    setTitlebar(c, c.first_tag.layout == awful.layout.suit.floating) -- or c.floating

    -- if awesome.startup
      -- and not c.size_hints.user_position
      -- and not c.size_hints.program_position then
        -- -- Prevent clients from being unreachable after screen count changes.
        -- awful.placement.no_offscreen(c)
    -- end
end)

-- Show titlebars on clients with floating property
client.connect_signal("property::floating", function(c)
    setTitlebar(c, c.floating or awful.layout.get(awful.screen.focused()) == awful.layout.suit.floating)
end)

-- Show titlebars on tags with the floating layout
tag.connect_signal("property::layout", function(t)
    for _, c in pairs(t:clients()) do
        setTitlebar(c, t.layout == awful.layout.suit.floating)
    end
end)

-- Focus urgent clients automatically
client.connect_signal("property::urgent", function(c)
    c.minimized = false
    c:jump_to()
end)

client.connect_signal("property::fullscreen", function(c)
    if c.fullscreen then
        gears.timer.delayed_call(function()
            if c.valid then
                c:geometry(c.screen.geometry)
            end
        end)
    end
end)

-- Double click titlebar timer, how long it takes for a 2 clicks to be considered a double click
function double_click_event_handler(double_click_event)
    if double_click_timer then
        double_click_timer:stop()
        double_click_timer = nil
        return true
    end
    double_click_timer = gears.timer.start_new(0.20, function() double_click_timer = nil return false end)
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            -- WILL EXECUTE THIS ON DOUBLE CLICK
            if double_click_event_handler() then
                c.maximized = not c.maximized
                c:raise()
            else
                awful.mouse.client.move(c)
            end
        end)
        -- awful.button({ }, 3, function()
            -- c:emit_signal("request::activate", "titlebar", {raise = true})
            -- awful.mouse.client.resize(c)
        -- end)
    )

    awful.titlebar(c, {size=dpi(26)}) : setup {
	    {
	        { -- Left
	            -- awful.titlebar.widget.iconwidget(c),
	            -- awful.titlebar.widget.floatingbutton (c),
	            buttons = buttons,
	            layout  = wibox.layout.fixed.horizontal
	        },
	        { -- Middle
	            { -- Title
	                align  = "left",
	                widget = awful.titlebar.widget.titlewidget(c)
	            },
	            buttons = buttons,
	            layout  = wibox.layout.flex.horizontal
	        },
	        { -- Right
	            awful.titlebar.widget.minimizebutton (c),
	            awful.titlebar.widget.maximizedbutton(c),
	            awful.titlebar.widget.closebutton    (c),
	            -- awful.titlebar.widget.stickybutton   (c),
	            -- awful.titlebar.widget.ontopbutton    (c),
	            layout = wibox.layout.fixed.horizontal()
	        },
	        layout = wibox.layout.align.horizontal
	    },
    	left = 8,
    	widget = wibox.container.margin
	}
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c) c:emit_signal("request::activate", "mouse_enter", {raise = false}) end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("property::maximized", function(c) if c.maximized then c.border_width = 0 else c.border_width = beautiful.border_width end end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = require("rules")
-- }}}

run_once('picom')
-- run_once('nm-applet')
-- run_once('megasync','--style Fusion', 'sleep 1.1')
-- run_once('udiskie','-s -a')
-- run_once('blueman-tray')
run_once('/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1')
run_once('dbus-update-activation-environment DISPLAY XAUTHORITY WAYLAND_DISPLAY')
run_once('clipmenud')
-- awful.spawn.with_shell('touchegg')

naughty.get_next_notification_id() -- reserve id to brightness notification
