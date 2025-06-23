-- Rules to apply to new clients (through the "manage" signal).
local awful = require("awful")

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_color = beautiful.border_normal,
                     maximized = false,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = require("bindings.clientkeys"),
                     buttons = require("bindings.clientbuttons"),
                     screen = awful.screen.preferred,
                     placement = awful.placement.centered + awful.placement.no_offscreen,
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
		    "nmtui",
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

    -- Rules
    { rule = { class = "polkit-gnome-authentication-agent-1" },
      	    properties = { ontop = true, focus = true } },
    { rule = { class = "Xsnow" },
      	    properties = { fullscreen = true, requests_no_titlebar = true, skip_taskbar = true, below = true } },
  	{ rule = { class = "wps" },
  	    properties = { titlebars_enabled = false } },
  	{ rule = { class = "Tilda" },
  	    properties = { floating = true, requests_no_titlebar = true} },
  	{ rule = { class = "Nl.hjdskes.gcolor3" },
  	    properties = { floating = true, sticky = true} },
    { rule = { class= "Gsimplecal" },
	    properties = { floating = true, border_width = 0, skip_taskbar = true, requests_no_titlebar = true, placement = awful.placement.top_right } },
    { rule = { class= "MEGAsync" },
	    properties = { floating = true, border_width = 0, skip_taskbar = true, titlebars_enabled = false, placement = awful.placement.top_right } },
	-- { rule = { name= "scratchpad" },
		-- properties = { floating = true, ontop = true, sticky = true, placement = awful.placement.centered } },
	{ rule = { name= "Picture-in-picture" },
		properties = { floating = true, ontop = true, sticky = true, placement = awful.placement.restore } },
	{ rule = { class= "Nitrogen" },
		properties = { floating = true, ontop = true, sticky = true, placement = awful.placement.bottom_right } },
    { rule = { class= "qvidcap" },
	    properties = { floating = true, ontop = true, sticky = true, focus = false, placement = awful.placement.bottom_right } },
	{ rule = { class="Dragon-drop" },
		properties = { ontop = true, sticky = true } },
	{ rule = { name="Torrential", instance="transmission" },
		properties = { floating = true } },	
	{ rule = { class="Heimer" },
		properties = { floating = false, fullscreen = false } },	
	{ rule = { class="mpv" },
		callback = function() if awful.layout.get(awful.screen.focused()) ~= awful.layout.suit.floating then awful.layout.set(awful.layout.suit.max) end end },
	{ rule = { class="Viewnior" }, callback = function() if awful.layout.get(awful.screen.focused()) ~= awful.layout.suit.floating then awful.layout.set(awful.layout.suit.max) end end },
	-- { rule = { class="okular" },
		-- properties = { switchtotag = true, tag = " 4 " },
		-- callback = function() awful.layout.set(awful.layout.suit.max, awful.screen.focused().tags[4]) end },
    { rule = { instance="typefast.io" },
        properties = { floating = false, tag = " 5 " } },
    { rule = { class="Inkscape" },
            properties = { maximized = false, tag = " 5 " } },
    { rule = { class="Blender" },
            properties = { maximized = false, tag = " 5 " } },
    { rule = { class="Flowblade" },
            properties = { maximized = false, tag = " 5 " } },
    { rule = { class="steam" },
            properties = { tag = " 6 " } },
    { rule = { class="heroic", name="Steam" },
            properties = { tag = " 6 " } },
    { rule = { class="Skype" },
    	properties = { tag = " 7 " } },
	{ rule = { class="VirtualBox Manager" },
        properties = { switchtotag = true, tag = " 7 " },
        callback = function() awful.layout.set(awful.layout.suit.max, awful.screen.focused().tags[7]) end },
    { rule = { class="discord", instance="discord" },
    	properties = { switchtotag = false, urgent = false, focus = false, tag = " 7 " } },
    { rule = { instance="web.whatsapp.com" },
    	properties = { width = 845, height = 860, floating = true, fullscreen = false, placement = awful.placement.right, tag = " 8 " } },
    { rule = { class="TelegramDesktop" },
    	properties = { placement = awful.placement.restore, floating = true, urgent = false, tag = " 8 " } },
    { rule = { name="ncspot" },
    	properties = { urgent = false, focus = false, tag = " 9 " } }
}

return awful.rules.rules
