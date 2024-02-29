-- joaopauloalbq
-------------------------------------------------------------------------------------------------------------------
local gears = require("gears")
local awful = require("awful")
-------------------------------------------------------------------------------------------------------------------
return gears.table.join(
    -- awful.key({ modkey, "Shift" }, "u",  function () awful.spawn.with_shell('history | head -n 1 | xargs -0 fish -c | bat -Pp | grep -Eo "(((http|https|ftp|gopher)|mailto)[.:][^ >\"\]*|www\.[-a-z0-9.]+)[^ .,;\>\">\):]" | rofi -dmenu -i -monitor -2 -theme hud | xargs xdg-open > /dev/null  2>&1') end,
        -- {description = "decreases width", group = "floating window"}),
    awful.key({ altkey }, "/",  function () awful.spawn("suit-hud",false) end,
        {description = "decreases width", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "Home",  function (c) c:relative_move( 75,   0, -150,   0) end,
        {description = "decreases width", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "End",   function (c) c:relative_move(-75,   0,  150,   0) end,
    	{description = "increases width", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "Prior", function (c) c:relative_move(  0, -75,   0,  150) end,
    	{description = "increases height", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "Next",  function (c) c:relative_move(  0,  75,   0, -150) end,
    	{description = "decreases height", group = "floating window"}),
    awful.key({ modkey, "Shift" }, "Up",    function (c) c:relative_move(  0, -75,   0,   0) end,
    	{description = "move up", group = "client"}),
    awful.key({ modkey, "Shift" }, "Down",  function (c) c:relative_move(  0,  75,   0,   0) end,
	    {description = "move down", group = "client"}),
    awful.key({ modkey, "Shift" }, "Left",  
        function (c) 
            if c.floating or c.first_tag.layout == awful.layout.suit.floating then
                c:relative_move(-75,   0,   0,   0) 
            else
                awful.client.swap.byidx( -1)
            end
        end,
    	{description = "move left", group = "client"}),
    awful.key({ modkey, "Shift" }, "Right", 
        function (c) 
            if c.floating or c.first_tag.layout == awful.layout.suit.floating then
                c:relative_move( 75,   0,   0,   0) 
            else
                awful.client.swap.byidx(  1)
            end
        end,
    	{description = "move right", group = "client"}),
   	
   	awful.key({}, "XF86Cut", function()
			awful.key.execute({}, "F11")
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
    awful.key({ modkey, "Shift"   }, "space",  awful.client.floating.toggle                     ,
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
    awful.key({ modkey,           }, "Down",   function (c) c.minimized = true end ,
              {description = "minimize", group = "client"}),       
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
    awful.key({ modkey, "Shift" }, "Return",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"})

)