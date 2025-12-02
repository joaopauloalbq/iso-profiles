local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi
-------------------------------------------------------------------------------------------------------------------
awesome.register_xproperty("ANIMATED", "boolean");
-------------------------------------------------------------------------------------------------------------------
-- Mouse resize
awful.mouse.resize.add_enter_callback(function (c) c:set_xproperty("ANIMATED", false) end, 'mouse.resize')
awful.mouse.resize.add_leave_callback(function (c) c:set_xproperty("ANIMATED", true) end, 'mouse.resize')

-- Mouse move
awful.mouse.resize.add_enter_callback(function (c) c:set_xproperty("ANIMATED", false) end, 'mouse.move')
awful.mouse.resize.add_leave_callback(function (c) c:set_xproperty("ANIMATED", true) end, 'mouse.move')
-------------------------------------------------------------------------------------------------------------------
-- Toggle titlebar on or off depending on <condition>. Creates titlebar if it doesn't exist
local function set_titlebar(client, condition)
    if condition then
        awful.titlebar.show(client)
    else
        awful.titlebar.hide(client)
    end
end
-------------------------------------------------------------------------------------------------------------------
tag.connect_signal("property::layout", function()
    if client.focus then
        client.focus:raise()
    end
end)

tag.connect_signal("property::layout", function(t)
    if t.layout == awful.layout.suit.floating then
        for _, c in pairs(t:clients()) do
            -- Get the last geometry when client was floating
            local floating_geometry = c.floating_geometry
            -- Show titlebars on tags with the floating layout
            awful.titlebar.show(c)
            -- Set the last geometry when client was floating
            c:geometry(floating_geometry)
        end
    else
        for _, c in pairs(t:clients()) do
            awful.titlebar.hide(c)
        end
    end
end)
-------------------------------------------------------------------------------------------------------------------
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if c.maximized then c.border_width = 0 else c.border_width = beautiful.border_width end
    
    set_titlebar(c, c.first_tag.layout == awful.layout.suit.floating) -- or c.floating

    -- if awesome.startup
      -- and not c.size_hints.user_position
      -- and not c.size_hints.program_position then
        -- -- Prevent clients from being unreachable after screen count changes.
        -- awful.placement.no_offscreen(c)
    -- end
end)

client.connect_signal("property::floating", function(c)
    -- Set the last geometry when client was floating
    c:geometry(c.floating_geometry)
end)

client.connect_signal("property::geometry", function(c)
    if c.floating then
        c.floating_geometry = c:geometry()
    elseif c.first_tag and c.first_tag.layout == awful.layout.suit.floating then
        c.floating_geometry = c:geometry()
    end
end)

-- Show titlebars on clients with floating property
-- client.connect_signal("property::floating", function(c)
--     set_titlebar(c, c.floating)
-- end)

-- Focus urgent clients automatically
client.connect_signal("property::urgent", function(c)
    c.minimized = false
    c:jump_to()
end)

client.connect_signal("property::fullscreen", function(c)
    c.screen = awful.screen.focused()
    
    if c.fullscreen then
        gears.timer.delayed_call(function()
            if c.valid then
                c:geometry(c.screen.geometry)
            end
        end)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

client.connect_signal("property::maximized", function(c)
    if c.maximized then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width
    end 
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Double click titlebar timer, how long it takes for a 2 clicks to be considered a double click
    local function double_click_event_handler()
        if double_click_timer then
            double_click_timer:stop()
            double_click_timer = nil
            return true
        end
        double_click_timer = gears.timer.start_new(0.20, function() double_click_timer = nil return false end)
    end
    
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, 
            function()
                c:emit_signal("request::activate", "titlebar", {raise = true})
                -- WILL EXECUTE THIS ON DOUBLE CLICK
                if double_click_event_handler() then
                    c.maximized = not c.maximized
                    c:raise()
                else
                    awful.mouse.client.move(c)
                end
            end
        )
    )

    awful.titlebar(c, {size = dpi(26)}) : setup {
	    {
	        { -- Left
	            -- awful.titlebar.widget.iconwidget     (c),
	            -- awful.titlebar.widget.floatingbutton (c),
                -- awful.titlebar.widget.stickybutton   (c),
                -- awful.titlebar.widget.ontopbutton    (c),
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
	            layout = wibox.layout.fixed.horizontal
	        },
	        layout = wibox.layout.align.horizontal
	    },
    	left = dpi(8),
    	widget = wibox.container.margin
	}
end)
-------------------------------------------------------------------------------------------------------------------
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function ()
    awful.spawn([[nitrogen --restore]], false)
end)
-------------------------------------------------------------------------------------------------------------------
awesome.connect_signal("exit", function(reason_restart)
    if reason_restart then
        local file = io.open("/tmp/awesomewm-last-selected-tags", "w+")
        if file then
            for s in screen do
                file:write(s.selected_tag.index, "\n")
            end
            file:close()
        end
    end
end)

awesome.connect_signal("startup", function()
    local file = io.open("/tmp/awesomewm-last-selected-tags", "r")
    local selected_tags = {}
    if file then
        for line in file:lines() do
            table.insert(selected_tags, tonumber(line))
        end
        file:close()
        
        for s in screen do
            if s.tags[selected_tags[s.index]] then
                s.tags[selected_tags[s.index]]:view_only()
            end
        end
    end
end)
