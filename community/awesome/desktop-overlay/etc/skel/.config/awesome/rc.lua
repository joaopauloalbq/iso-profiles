-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- More widgets, layouts and utilities 
local lain = require("lain")
local markup = lain.util.markup
-- Overview
local revelation = require("revelation")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Menu
-- local freedesktop = require("freedesktop")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- require("awful.hotkeys_popup.keys")
local dpi = require('beautiful').xresources.apply_dpi

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, there were errors during startup!", text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true
        
        naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, an error happened!",
        text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/nord-pink/theme.lua")
revelation.init({charorder = "asdfqwergtbvcxz"})

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = "micro"
editor_cmd = terminal .. " -x " .. editor

naughty.config.defaults.border_width = beautiful.notification_border_width
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.padding = dpi(14)
naughty.config.spacing = dpi(6)
naughty.config.icon_dirs = {"/usr/share/icons/Papirus-Dark/48x48/status/", "/usr/share/icons/Papirus-Dark/48x48/categories/"}
naughty.config.icon_formats = {"svg"}

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    -- lain.layout.termfair,
    -- lain.layout.termfair.center,
    -- lain.layout.cascade,
    -- lain.layout.cascade.tile,
    -- lain.layout.centerwork,
    -- lain.layout.centerwork.horizontal,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    -- awful.layout.suit.magnifier,
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
}
-- }}}

-- {{{ Menu
-- To add the menu to a widget:
myexitmenu = {
    { "Shutdown", "systemctl poweroff" }, --, menubar.utils.lookup_icon("system-shutdown")
    { "Suspend", "systemctl suspend" }, --, menubar.utils.lookup_icon("system-suspend") 
    { "Hibernate", "systemctl hibernate" }, --, menubar.utils.lookup_icon("system-hibernate")
    { "Restart", "systemctl reboot" }, --, menubar.utils.lookup_icon("system-reboot")
    { "Logout", function() awesome.quit() end }, --, menubar.utils.lookup_icon("system-log-out") 
}

mylauncher = awful.widget.launcher({ image = ".config/awesome/themes/nord-pink/suit-logo.png", command = "rofi -modi drun -show drun -theme grid -location 1 -yoffset 37 -xoffset 14" })

suitSettingsLauncher = awful.widget.launcher({ image = "/usr/share/icons/Papirus-Dark/24x24/panel/fcitx-mozc-properties.svg", command = 'rofi -modi "settings:suit-settings" -show settings -theme settings' })

mydesktopmenu = awful.menu({ items = { { "Hotkeys", function() return false, hotkeys_popup.show_help end },
                                       { "Wallpaper", function() mouse.coords({x=awful.screen.focused().geometry.width - 200, y=mouse.coords().y}) awful.spawn('rofi -modi "wallpaper:suit-wallpaper" -show wallpaper -theme wallpaper') end},
                                       { "Settings", function() mouse.coords({x=awful.screen.focused().geometry.width - 200, y=mouse.coords().y}) awful.spawn.with_shell('rofi -modi "settings:suit-settings" -show settings -theme settings') end},
                                       { "Exit", myexitmenu }
                                    }})


-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
mytextclock = wibox.widget.textclock(" %a %d, %H:%M ")
mytextclock:buttons( gears.table.join(
                        awful.button({ }, 1, function () awful.spawn("gsimplecal", false) end),
                        awful.button({ }, 4, function () awful.spawn("gsimplecal next_month", false) end),
                        awful.button({ }, 5, function () awful.spawn("gsimplecal prev_month", false) end)))
                        
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ }, 2, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                         end),
                    awful.button({ modkey }, 1, function(t)
                                                    if client.focus then
                                                        client.focus:move_to_tag(t)
                                                    end
                                                end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                                    if client.focus then
                                                        client.focus:toggle_tag(t)
                                                    end
                                                end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
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

-- local function set_wallpaper(s)
    -- -- Wallpaper
    -- if beautiful.wallpaper then
        -- local wallpaper = beautiful.wallpaper
        -- -- If wallpaper is a function, call it with the screen
        -- if type(wallpaper) == "function" then
            -- wallpaper = wallpaper(s)
        -- end
        -- gears.wallpaper.maximized(wallpaper, s, true)
    -- end
-- end

local function set_wallpaper(s)
    awful.spawn("nitrogen --restore", false)
end

local function run_once(exeBefore, exeCmd, exeArgs)
    awful.spawn.easy_async('pidof ' .. exeCmd, function(stdout, stderr, exitreason, exitcode)
        if exitcode ~= 0 then
            awful.spawn.with_shell(exeBefore .. exeCmd .. exeArgs)
        end
    end)
end

local function rallpaper() 
    awful.spawn.with_line_callback('xdg-user-dir PICTURES', {
        stdout = function(PICTURES_DIR)
            awful.spawn.with_shell(terminal.." -T 'Set wallpaper' --role='set-wallpaper' -x ranger --confdir=$HOME/.config/rallpaper " .. PICTURES_DIR .. "/Wallpapers")
        end,}) 
end

-- Toggle titlebar on or off depending on s. Creates titlebar if it doesn't exist
local function setTitlebar(client, s)
    if s then
        -- if client.titlebar == nil then
            -- client:emit_signal("request::titlebars", "rules", {})
        -- end
        awful.titlebar.show(client)
    else 
        awful.titlebar.hide(client)
    end
end

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

local function backlight(mode)
	awful.spawn.easy_async('light -' .. mode .. ' 10', function()
        awful.spawn.easy_async('light -G', function(brightness)
        	if notification_display ~= nil then
        		notification_display = naughty.notify ({
        			replaces_id	= notification_display.id,
        			text        = string.rep("■", math.ceil(brightness * 0.3)),
        			icon        = getBrightnessIcon(tonumber(brightness)),
        			-- width	 = 346,
        			timeout  	= t_out,
        			preset   	= preset,
        			ignore_suspend = true
        		})
        	else
        		notification_display = naughty.notify ({
        			text     = string.rep("■", math.ceil(brightness * 0.3)),
        			icon     = getBrightnessIcon(tonumber(brightness)),
        			-- width	 = 346,
        			timeout  = t_out,
        			preset   = preset,
           			ignore_suspend = true
        		})
        	end
        end)
	end)
end

local function getAudioIcon(vol)
    if vol > 65 then
        return "notification-audio-volume-high"
    elseif vol >= 35 then
        return "notification-audio-volume-medium"
    else
        return "notification-audio-volume-low"
    end
end

local function audio(mode)
	awful.spawn.easy_async('pamixer --' .. mode .. ' 5', function()
        awful.spawn.easy_async('pamixer --get-volume', function(vol)
        	if notification_audio ~= nil then
        		notification_audio = naughty.notify ({
        			replaces_id	= notification_audio.id,
        			text        = string.rep("■", math.ceil(vol * 0.3)),
        			icon        = getAudioIcon(tonumber(vol)),
        			timeout  	= t_out,
        			preset   	= preset,
           			ignore_suspend = true
        		})
        	else
        		notification_audio = naughty.notify ({
        			text        = string.rep("■", math.ceil(vol * 0.3)),
        			icon        = getAudioIcon(tonumber(vol)),
        			timeout     = t_out,
        			preset      = preset,
        			ignore_suspend = true
        		})
        	end
        end)
	end)
end

local function audioMute()
    awful.spawn.easy_async('pamixer --toggle-mute', function() 
        awful.spawn.easy_async('pamixer --get-volume', function(vol) 
            awful.spawn.easy_async('pamixer --get-mute', function(isMuted)
                if notification_audio ~= nil then
                    if isMuted == "true\n" then
                        notification_audio = naughty.notify ({
                            replaces_id	= notification_audio.id,
                            fg          = "#676767",
                            text        = string.rep("■", math.ceil(vol * 0.3)),
                            icon        = "notification-audio-volume-muted",
                            timeout  	= t_out,
                            preset   	= preset,
                            ignore_suspend = true
                         })
                    else
                        notification_audio = naughty.notify ({
                            replaces_id = notification_audio.id,
                            text        = string.rep("■", math.ceil(vol * 0.3)),
                            icon        = getAudioIcon(tonumber(vol)),
                            timeout  	= t_out,
                            preset   	= preset,
                            ignore_suspend = true
                        })
                    end
                else
                    if isMuted == "true\n" then
                        notification_audio = naughty.notify ({
                            fg          = "#676767",
                            text        = string.rep("■", math.ceil(vol * 0.3)),
                            icon        = "notification-audio-volume-muted",
                            timeout     = t_out,
                            preset      = preset,
                            ignore_suspend = true
                        })
                    else
                        notification_audio = naughty.notify ({
                            text        = string.rep("■", math.ceil(vol * 0.3)),
                            icon        = getAudioIcon(tonumber(vol)),
                            timeout     = t_out,
                            preset      = preset,
                            ignore_suspend = true
                        })
                    end
                end
            end)
        end)
    end)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 " }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
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
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 24 }) -- opacity = 0.90
 	-- os.setlocale(os.getenv("LANG"))
     	 	 	
    -- Add widgets to the wibox
    s.mywibox:setup {
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
            
            wibox.widget.systray(),
            -- awful.widget.keyboardlayout(),
            suitSettingsLauncher,
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
globalkeys = gears.table.join(
	-- gaps 
	awful.key({ modkey, }, "=", function () awful.tag.incgap(beautiful.useless_gap)    end,
	{description = "increase gap", group = "layout"}),
	awful.key({ modkey, }, "-", function () awful.tag.incgap(-beautiful.useless_gap)    end,
	{description = "decrease gap", group = "layout"}),
	awful.key({ modkey, }, "0", function () awful.screen.focused().selected_tag.gap = beautiful.useless_gap    end,
	{description = "restore gap", group = "layout"}),

	awful.key({ altkey,           }, "space",  revelation),
	awful.key({ modkey, altkey }, "space", function()
            revelation({rule={class="conky"}, is_excluded=true, 
            curr_tag_only=true}) end),
    
    awful.key({ modkey, "Control" }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey, "Control" }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
 	awful.key({ modkey, "Control", altkey  }, "Left", function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
   	awful.key({ modkey, "Control", altkey  }, "Right", function () lain.util.tag_view_nonempty(1) end,
   			  {description = "view  previous nonempty", group = "tag"}),
              
	-- awful.key({ modkey, 		}, "BackSpace", function()
		-- naughty.toggle()
		-- if naughty.is_suspended() then
			-- naughty.notify({ title = "Do not disturb",
			 				 -- text = "Ativado",
			 				 -- icon = "notification-disabled",
			 				 -- ignore_suspend = true })
		-- else
			-- naughty.notify({ title = "Do not disturb",
			 				 -- text = "Desativado",
			 				 -- icon = "preferences-desktop-notification-bell",
			 				 -- ignore_suspend = true })
		-- end
	-- end, {description = "Do not disturb", group = "Notification"}),
	
	awful.key({ modkey, 		}, "Delete", function()
		naughty.destroy_all_notifications()
	end),
              
	-- Move client to prev/next tag and switch to it
	awful.key({ modkey, "Control" , "Shift" }, "Left",
	    function ()
	        -- get current tag
	        local t = client.focus and client.focus.first_tag or nil
	        if t == nil then
	            return
	        end
	        -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
	        local tag = client.focus.screen.tags[(t.name - 2) % 9 + 1]
            client.focus:move_to_tag(tag)
            -- awful.client.movetotag(tag) -- deprecated
	        tag:view_only()
	        -- awful.tag.viewprev() -- deprecated
	    end,
	        {description = "move client to previous tag and switch to it", group = "layout"}),
	awful.key({ modkey, "Control" , "Shift" }, "Right",
	    function ()
	        -- get curreìnt tag
	        local t = client.focus and client.focus.first_tag or nil
	        if t == nil then
	            return
	        end
	        -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
	        local tag = client.focus.screen.tags[(t.name % 9) + 1]
	        client.focus:move_to_tag(tag)
	        -- awful.client.movetotag(tag) -- deprecated
	        tag:view_only()
	        -- awful.tag.viewnext() -- deprecated
	    end,
	        {description = "move client to next tag and switch to it", group = "layout"}),
	
	-- Window navigation (by id)
    awful.key({ modkey,           }, "Right",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "Left",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}),
    
    -- Window navigation (by direction)
    -- awful.key({ modkey }, "Down",
            -- function()
                -- awful.client.focus.bydirection("down")
                -- if client.focus then client.focus:raise() end
            -- end),
        -- awful.key({ modkey }, "Up",
            -- function()
                -- awful.client.focus.bydirection("up")
                -- if client.focus then client.focus:raise() end
            -- end),
        -- awful.key({ modkey }, "Left",
            -- function()
                -- awful.client.focus.bydirection("left")
                -- if client.focus then client.focus:raise() end
            -- end),
        -- awful.key({ modkey }, "Right",
            -- function()
                -- awful.client.focus.bydirection("right")
                -- if client.focus then client.focus:raise() end
            -- end),
    
    awful.key({ altkey,           }, "Escape",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
   
    -- Layout manipulation
    awful.key({ altkey, "Control" }, "Right", function () awful.screen.focus_relative( 1) end,
              {description = "change screen focus", group = "screen"}),
	awful.key({ altkey, "Control" }, "Left",  function () awful.screen.focus_relative(-1) end,
              {description = "change screen focus", group = "screen"}),
              
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ altkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, altkey    }, "Return", function () awful.spawn(terminal .. " --drop-down") end,
              {description = "open a dropdown terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey }, "Prior",     function () awful.tag.incmwfact( 0.03)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey }, "Next",     function () awful.tag.incmwfact(-0.03)          end,
              {description = "decrease master width factor", group = "layout"}),
	awful.key({ altkey }, "Prior",     function () awful.client.incwfact( 0.10)          end,
              {description = "increase non-master width factor", group = "layout"}),
    awful.key({ altkey }, "Next",     function () awful.client.incwfact(-0.10)          end,
              {description = "decrease non-master width factor", group = "layout"}),
    
    awful.key({ modkey, altkey }, "=",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, altkey }, "-",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, altkey }, "]",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, altkey }, "[",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, altkey }, "Next", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, altkey }, "Prior", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, }, "Up",
              function ()
                  local c = awful.client.restore()
                  if c then
                    c:emit_signal("request::activate", "key.unminimize", {raise = true})
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Launchers
	awful.key({ modkey },            "o",     function () awful.spawn('rofi -modi "settings:suit-settings" -show settings -theme settings', false) end,
		    {description = "show windows (all desktops)", group = "launcher"}),
		    
	awful.key({ modkey },            "a",     function () awful.spawn("rofi -modi 'window,windowcd' -show window", false) end,
			{description = "show windows (all desktops)", group = "launcher"}),
	
	awful.key({ modkey },            "b",     function () awful.spawn("rofi-bluetooth", false) end,
				{description = "bluetooth", group = "launcher"}),
	
	awful.key({ modkey },            "k",     function () awful.spawn("rofi -modi calc -show calc -no-show-match -no-sort", false) end,
			{description = "calculator", group = "launcher"}),
			
	awful.key({ modkey },            "c",     function () awful.spawn.with_shell("clipmenu -p  && xdotool key shift+Insert", false) end,
			{description = "clipboard", group = "launcher"}),
			
    -- awful.key({ modkey, "Control" }, "c",     function () awful.spawn.with_shell("clipmenu -theme clipdel -p  && clipdel -d $(xsel -o)", false) end,
    awful.key({ modkey, "Control" }, "c",     function () awful.spawn.with_shell("rofi -modi 'delclip:suit-delclip' -show delclip -theme clipdel -p ", false) end,
    		{description = "Delete clipboard entries", group = "launcher"}),
			
	awful.key({ modkey },            "d",     function () awful.spawn("rofi -modi drun -show drun -theme grid", false) end,
	        {description = "open applications", group = "launcher"}),
	
	awful.key({ modkey },            "e",     function () awful.spawn.with_shell("clipctl disable; rofi -modi emoji -show emoji -emoji-format {emoji} -theme emoji -kb-custom-1 Ctrl+c ; clipctl enable", false) end,
			{description = "emoji picker", group = "launcher"}),              
			
	awful.key({ modkey },            "g",     function () awful.spawn("rofi -modi filebrowser -show filebrowser", false) end,
			{description = "file browser", group = "launcher"}),
	              		              
	awful.key({ modkey },            "m",     function () awful.spawn.with_shell("udiskie-dmenu -matching regex -dmenu -i -no-custom -multi-select -p ") end,
			{description = "Mount devices", group = "launcher"}),
		 	
	awful.key({ modkey ,         },  "n",     function () awful.spawn("networkmanager_dmenu", false) end,
            {description = "network launcher", group = "launcher"}),
    
    awful.key({ modkey, altkey },  "p",     function () menubar.show() end ),
            		 	
    awful.key({ modkey },  "p",     function () awful.spawn.with_shell("suit-monitor", false) end,
            {description = "Display Mode", group = "launcher"}),        
			
	awful.key({ modkey , "Shift" },  "q",     function () awful.spawn("rofi -modi 'powermenu:suit-powermenu' -show powermenu -theme power", false) end,
		 	{description = "Power menu", group = "launcher"}),
	              		              	              	              		              	             
	-- awful.key({ modkey },            "s",     function () awful.spawn.with_shell('xdg-open "$(plocate -e -i --regex "$HOME/[^.]" | rofi -dmenu -i -keep-right -p  -auto-select)"') end,
	-- awful.key({ modkey },            "s",     function () awful.spawn.with_shell('xdg-open "$(plocate -d "$HOME/.cache/plocate.db" -e -i --regex "$HOME/[^.]" | rofi -dmenu -i -keep-right -p  -auto-select)" || updatedb -l 0 -U "$HOME" -e "$HOME/.config" -e "$HOME/.local" -e "$HOME/.cache" -e "$HOME/Games" -o "$HOME/.cache/plocate.db"') end,
	-- awful.key({ modkey },            "s",     function () awful.spawn.with_shell('xdg-open "$(fd . -c never | rofi -dmenu -i -keep-right -p )"') end, -- -theme-str "element-icon {enabled: false;}"
	awful.key({ modkey },            "s",     function () awful.spawn.with_shell("rofi -modi 'search:suit-search' -show search -kb-accept-alt '' -kb-custom-1 'Shift+Return'") end,
	        {description = "File searcher", group = "launcher"}),
		 	
	awful.key({ modkey },            "w",     function () awful.spawn("rofi -modi 'windowcd,window' -show windowcd", false) end,
		    {description = "show windows (current desktop)", group = "launcher"}),
		              
	awful.key({ modkey },         "Escape",     function () awful.spawn.with_shell("seltr auto pt-BR") end,
			{description = "Translate selected text", group = "launcher"}),
			
	-- Apps
	awful.key({ modkey , "Shift" },  "b",     function () awful.spawn(terminal .. " -e btop -T btop") end,
				 {description = "btop", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "c",     function () awful.spawn(terminal .. " -e micro") end,
				 {description = "micro text editor", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "d", function () awful.spawn('rofi -modi "wallpaper:suit-wallpaper" -show wallpaper -theme wallpaper') end,
				 {description = "wallpaper", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "f",     function () awful.spawn(terminal .. " -e ranger -T ranger") end,
				 {description = "ranger file manager", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "h",     function () awful.spawn(terminal .. " -e htop -T htop") end,
				 {description = "htop", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "n",     function () awful.spawn(terminal .. " -e nmtui", {floating = true}) end,
				 {description = "network manager", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "s",     function () awful.spawn(terminal .. " -e ncspot -I spotify", {tag = " 9 ", focus = false }) end, 
	             {description = "ncspot", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "v",     function () awful.spawn("code") end,
				 {description = "vs code", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "w",     function () awful.spawn("brave") end,
				 {description = "web browser", group = "launcher"}),
	awful.key({ altkey , "Shift" },  "w",     function () awful.spawn("brave --incognito") end),

	-- Lockscreen
    awful.key({ modkey },            "l",     function () awful.spawn("suit-lockscreen") end,
        {description = "Lock Screen", group = "launcher"}),
        
    -- Bright Keys
    awful.key({}, "XF86MonBrightnessUp", function() backlight("A") end), 
    awful.key({}, "XF86MonBrightnessDown", function() backlight("U") end),
              
	-- Volume Keys
    awful.key({}, "XF86AudioRaiseVolume", function() audio("increase") end), 
    awful.key({}, "XF86AudioLowerVolume", function() audio("decrease") end), 
    awful.key({}, "XF86AudioMute", function() audioMute() end),
    
	-- Media Keys	
    awful.key({}, "XF86AudioPlay", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any play-pause", false)
    end),    
    awful.key({modkey}, "/", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any play-pause", false)
    end),
    
    awful.key({}, "XF86AudioNext", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any next", false)
    end),
    awful.key({modkey}, ".", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any next", false)
    end),
    
    awful.key({}, "XF86AudioPrev", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any previous", false)
    end),
    awful.key({modkey}, ",", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any previous", false)
    end),
	   
	-- Screenshot
    awful.key({}, "Print", function ()
        local name = os.date("Imagens/Screenshots/Screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.easy_async_with_shell("maim " .. name, function()
            naughty.notify({ title = "Screenshot captured",
				             text  = name,
        			     	 icon  = "preferences-desktop-wallpaper",
        			     	 run   = function() awful.spawn.with_shell('xdg-open ' .. name) end })
        end) 
    end, {description = "Print desktop", group = "Screenshot"}),
    
    awful.key({ modkey }, "Print", function ()
        local name = os.date("Imagens/Screenshots/Screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.easy_async_with_shell("maim -i $(xdotool getactivewindow) " .. name, function()
            naughty.notify({ title = "Screenshot captured",
			    	         text  = name,
        		    	 	 icon  = "preferences-desktop-wallpaper",
        		    	 	 run   = function() awful.spawn.with_shell('xdg-open ' .. name)  end })
        end)
    end, {description = "Print window", group = "Screenshot"}),
    
    awful.key({ "Shift" }, "Print", nil, function ()
        local name = os.date("Imagens/Screenshots/Screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.easy_async_with_shell("maim -s " .. name, function(stdout, stderr, exitreason, exitcode)            
            if exitcode == 0 then        
                naughty.notify({ title = "Screenshot captured",
    				             text  = name,
            			 	     icon  = "preferences-desktop-wallpaper",
            			 	     run   = function() awful.spawn.with_shell('xdg-open ' .. name)  end })
            end
        end)
    end, {description = "Print area", group = "Screenshot"}),
    
    awful.key({ "Control" }, "Print", nil, function ()
        awful.spawn.with_shell("maim -s -k | xclip -selection c -t image/png && notify-send 'Screenshot captured' 'to clipboard' -i 'preferences-desktop-wallpaper'")
    end, {description = "Print area to clipboard", group = "Screenshot"}),
    
    awful.key({ modkey }, "z", nil, function ()
        awful.spawn.easy_async("xcolor -s", function()
            awful.spawn.with_line_callback("xclip -selection clipboard -o", {
                stdout = function(color)
                    awful.spawn.easy_async_with_shell('convert $HOME/.local/share/color.png -fill "'.. color .. '" -colorize 100 $HOME/.local/share/color.png', function() 
                        naughty.notify({
                            title = color,
                            text  = "copied to clipboard",
                            icon  = ".local/share/color.png",
                            border_color = color,
                            ignore_suspend = true
                        })                
                    end)
                end,
            })
        end)
    end, {description = "Color picker", group = "launcher"}),

	-- Kill app
    awful.key({ altkey, "Control" }, "Delete", nil, function ()
            awful.spawn("xkill") 
    end, {description = "Kill app", group = "client"}),

	awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() 
	end, {description = "run prompt", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ altkey }, "/",  function () awful.spawn("suit-hud",false) end,
        {description = "decreases width", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "Home",  function (c) c:relative_move( 50,   0, -100,   0) end,
        {description = "decreases width", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "End",   function (c) c:relative_move(-50,   0,  100,   0) end,
    	{description = "increases width", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "Prior", function (c) c:relative_move(  0, -50,   0,  100) end,
    	{description = "increases height", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "Next",  function (c) c:relative_move(  0,  50,   0, -100) end,
    	{description = "decreases height", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "Up",    function (c) c:relative_move(  0, -60,   0,   0) end,
    	{description = "move up", group = "client"}),
    awful.key({ modkey, "Shift" }, "Down",  function (c) c:relative_move(  0,  60,   0,   0) end,
	    {description = "move down", group = "client"}),
    awful.key({ modkey, "Shift" }, "Left",  
        function (c) 
            if c.floating or c.first_tag.layout == awful.layout.suit.floating then
                c:relative_move(-60,   0,   0,   0) 
            else
                awful.client.swap.byidx( -1)
            end
        end,
    	{description = "move left", group = "client"}),
    awful.key({ modkey, "Shift" }, "Right", 
        function (c) 
            if c.floating or c.first_tag.layout == awful.layout.suit.floating then
                c:relative_move( 60,   0,   0,   0) 
            else
                awful.client.swap.byidx(  1)
            end
        end,
    	{description = "move right", group = "client"}),
   	
   	awful.key({}, "XF86Cut", function()
			awful.spawn("xdotool key F11", false)
   	   	end),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
	awful.key({ modkey, "Control" }, "t",	   function(c) awful.titlebar.toggle(c) 	  	end,
	          {description = "toggle title bar", group = "client"}),
    awful.key({ modkey, 		  }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey,           }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ altkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ altkey, "Control", "Shift" }, "Left",      function (c) c:move_to_screen(c.screen.index-1)   end,
              {description = "move to screen", group = "screen"}),
	awful.key({ altkey, "Control", "Shift" }, "Right",      function (c) c:move_to_screen(c.screen.index+1)   end,
	              {description = "move to screen", group = "screen"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
	awful.key({ modkey,           }, "y",      function (c) c.sticky = not c.sticky            end,
              {description = "toggle sticky window", group = "client"}),
    awful.key({ modkey,           }, "Down",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    
    awful.key({ modkey, "Shift" }, "Return",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"})

    -- awful.key({ modkey, "Control" }, "m",
        -- function (c)
            -- c.maximized_vertical = not c.maximized_vertical
            -- c:raise()
        -- end ,
        -- {description = "(un)maximize vertically", group = "client"}),
    -- awful.key({ modkey, "Shift"   }, "m",
        -- function (c)
            -- c.maximized_horizontal = not c.maximized_horizontal
            -- c:raise()
        -- end ,
        -- {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ altkey }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag #.
        awful.key({ altkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
		-- Move client to tag # and switch to it.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function ()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then
                            client.focus:move_to_tag(tag)
                            tag:view_only()
                        end
                   end
                end,
                {description = "move client and switch to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, altkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

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
root.keys(globalkeys)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    setTitlebar(c, c.first_tag.layout == awful.layout.suit.floating) -- or c.floating

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
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

-- Show titlebars on tags with the floating layout
tag.connect_signal("property::layout", function(t)
    for _, c in pairs(t:clients()) do
        setTitlebar(c, t.layout == awful.layout.suit.floating)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
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

-- Hook called when a client spawns
-- client.connect_signal("manage", function(c)
    -- setTitlebar(c, c.first_tag.layout == awful.layout.suit.floating) -- or c.floating
-- end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c) c:emit_signal("request::activate", "mouse_enter", {raise = false}) end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("property::maximized", function(c) if c.maximized then c.border_width = 0 else c.border_width = beautiful.border_width end end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.centered,
                     size_hints_honor = false
                   }
    },

    -- Add titlebars to normal clients and dialogs
    { rule_any = { type = { "normal", "dialog" }
        }, properties = { titlebars_enabled = false }
    },
      
    -- Floating clients.
    { rule_any = {
        instance = {
            "DTA",  -- Firefox addon DownThemAll.
            "copyq",  -- Includes session name in class.
            "pinentry",
            "gnome-pomodoro",
            "nm-connection-editor",
            "pavucontrol",
            "file-roller",
		},
		class = {
            "Rofi",
            "Blueman-manager",
            "Gpick",
            "Kruler",
            "MessageWin",  -- kalarm.
            "Sxiv",
            "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
            "Wpa_gui",
            "veromix",
            "xtightvncviewer",
            "Gnome-pomodoro",
            "Nm-connection-editor",
            "Pavucontrol",
            "File-roller",
            "SimpleScreenRecorder",
            "Gnome-calculator"
		},
		-- Note that the name property shown in xprop might be set slightly after creation of the client
		-- and the name shown there might not match defined rules here.
		name = {
            "Event Tester",  -- xev.
            "galculator",
            "Settings",
            "com.github.davidmhewitt.torrential",
		},
		role = {
            "AlarmWindow",  -- Thunderbird's calendar.
            "ConfigManager",  -- Thunderbird's about:config.
            "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            "xfce4-terminal-dropdown",
		}
    }, properties = { floating = true }},
      
    -- Steam Games
    {
        rule_any = { class = {"^steam_app$"} },
        properties = { fullscreen = true }, --, size_hints_honor = true, floating = true, ontop = true, tag = " 6 " 
    },
    -- Steam Client
    {
        -- Most Steam windows (friends list, "Activate a new product", "An update
        -- is available", etc.) should be floating…
        rule_any = { class = {"Steam"} },
        -- …but not the main window
        exclude_any = { name = {"Steam"} }, -- TODO: Identify the main window
        properties = { floating = true, focus = false, size_hints_honor = true, tag = " 6 " },
    },

    -- Rules
    -- { rule = { class= "Rofi" },
	    -- properties = { floating = true, skip_taskbar = true, type = "dock" } },
    { rule = { class = "Xsnow" },
      	    properties = { fullscreen = true, requests_no_titlebar = true, skip_taskbar = true, below = true } },
  	{ rule = { class = "conky" },
  	    properties = { floating = true, requests_no_titlebar = true, border_width = 0 } },
  	{ rule = { class = "Gcolor3" },
  	    properties = { floating = true, sticky = true} },
    { rule = { class= "Gsimplecal" },
	    properties = { floating = true, border_width = 0, skip_taskbar = true, requests_no_titlebar = true, placement = awful.placement.top_right } },
    { rule = { class= "MEGAsync" },
	    properties = { floating = true, border_width = 0, skip_taskbar = true, titlebars_enabled = false, placement = awful.placement.top_right } },
	{ rule = { name= "Picture-in-picture" },
		properties = { floating = true, ontop = true, sticky = true, placement = awful.placement.restore } },
	{ rule = { class= "Nitrogen" },
		properties = { floating = true, ontop = true, sticky = true, placement = awful.placement.bottom_right } },
    { rule = { class= "Xfce4-terminal", role="set-wallpaper" },
		properties = { floating = true, ontop = true, sticky = true, placement = awful.placement.bottom_right } },
    { rule = { class= "qvidcap" },
	    properties = { floating = true, ontop = true, sticky = true, focus = false, placement = awful.placement.bottom_right } },
	{ rule = { class="Dragon-drop" },
		properties = { ontop = true, sticky = true } },
	{ rule = { name="Torrential" },
		properties = { floating = true } },	
	{ rule = { class="Heimer" },
		properties = { floating = false, fullscreen = false } },	
	{ rule = { class= "mpv" },
		callback = function() 
		    if awful.layout.get(awful.screen.focused()) ~= awful.layout.suit.floating then
		        awful.layout.set(awful.layout.suit.max)
            end
        end },
	{ rule = { class= "Viewnior" },
		callback = function() 
            if awful.layout.get(awful.screen.focused()) ~= awful.layout.suit.floating then
                awful.layout.set(awful.layout.suit.max)
            end
        end },
	{ rule = { class="okular" },
		properties = { switchtotag = true, tag = " 4 " },
		callback = function() awful.layout.set(awful.layout.suit.max, awful.screen.focused().tags[4]) end },
    { rule = { instance="typefast.io" },
        properties = { floating = false, tag = " 5 " } },
    { rule = { class="Inkscape" },
            properties = { maximized = false, tag = " 5 " } },
    { rule = { class="Blender" },
            properties = { maximized = false, tag = " 5 " } },
    { rule = { class="Flowblade" },
            properties = { maximized = false, tag = " 5 " } },
    { rule = { class="heroic" },
            properties = { tag = " 6 " } },
    { rule = { class="Skype" },
    	properties = { tag = " 7 " } },
	{ rule = { class="VirtualBox Manager" },
        properties = { switchtotag = true, tag = " 7 " },
        callback = function() awful.layout.set(awful.layout.suit.max, awful.screen.focused().tags[7]) end },
    { rule = { class="discord" },
    	properties = { switchtotag = false, urgent = false, focus = false, tag = " 7 " } },
    { rule = { instance="web.whatsapp.com" },
    	properties = { width = 845, height = 860, floating = true, placement = awful.placement.right, tag = " 8 " } },
    { rule = { class="TelegramDesktop" },
    	properties = { placement = awful.placement.restore, floating = true, urgent = false, tag = " 8 " } }
}
-- }}}

run_once('','picom','')
run_once('','nm-applet','')
run_once('sleep 0.8 && ','pa-applet',' --disable-key-grabbing')
-- run_once("sleep 0.9 && ","cbatticon"," -i 'level' -l 5 -c 'systemctl hibernate' -n")
run_once('sleep 1 && DO_NOT_UNSET_QT_QPA_PLATFORMTHEME=1 DO_NOT_SET_DESKTOP_SETTINGS_UNAWARE=1 ','megasync',' --style Fusion')
-- run_once('','udiskie',' -s -a')
-- run_once('','blueman-tray','')
run_once('','/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1','')
run_once('','gnome-keyring-daemon',' --unlock')
run_once('','clipmenud','')
awful.spawn.with_shell('touchegg')
