-- joaopauloalbq
-------------------------------------------------------------------------------------------------------------------
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local revelation = require("revelation")
-------------------------------------------------------------------------------------------------------------------
local function tag_view_nonempty(direction)
    local tags = awful.screen.focused().tags
    local selected_tag_index = awful.screen.focused().selected_tag.index

    local i = selected_tag_index
    repeat
        i = i + direction

        if i > #tags then
            i = i - #tags
        end
        if i < 1 then
            i = i + #tags
        end

        if #tags[i]:clients() > 0 then
            tags[i]:view_only()
            return
        end
    until (i == selected_tag_index)
end
-------------------------------------------------------------------------------------------------------------------
local globalkeys = gears.table.join(
    -- gaps
	awful.key({ modkey, }, "=", function () awful.tag.incgap(beautiful.useless_gap)    end,
	{description = "increase gap", group = "layout"}),
	awful.key({ modkey, }, "-", function () awful.tag.incgap(-beautiful.useless_gap)    end,
	{description = "decrease gap", group = "layout"}),
	awful.key({ modkey, }, "0", function () awful.screen.focused().selected_tag.gap = beautiful.useless_gap    end,
	{description = "restore gap", group = "layout"}),

	awful.key({ modkey,           }, "space",  revelation),
	awful.key({ modkey, altkey }, "space", function()
            revelation({curr_tag_only=true}) end),
    
    awful.key({ modkey, "Control" }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey, "Control" }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
 	awful.key({ modkey, altkey, "Control"  }, "Left", function () tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
   	awful.key({ modkey, altkey, "Control"  }, "Right", function () tag_view_nonempty(1) end,
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
	
	awful.key({ modkey }, "Delete", function()
		naughty.destroy_all_notifications()
	end),
              
	-- Move client to prev/next tag and switch to it
	awful.key({ modkey, "Control", "Shift" }, "Left",
	    function ()
	        -- get current tag
	        local t = client.focus and client.focus.first_tag or nil
	        if t == nil then
	            return
	        end
	        -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
	        local tag = client.focus.screen.tags[(t.name - 2) % 9 + 1]
            client.focus:move_to_tag(tag)
	        tag:view_only()
	    end,
	        {description = "move client to previous tag and switch to it", group = "layout"}),
	awful.key({ modkey, "Control", "Shift" }, "Right",
	    function ()
	        -- get curreìnt tag
	        local t = client.focus and client.focus.first_tag or nil
	        if t == nil then
	            return
	        end
	        -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
	        local tag = client.focus.screen.tags[(t.name % 9) + 1]
	        client.focus:move_to_tag(tag)
	        tag:view_only()
	    end,
	        {description = "move client to next tag and switch to it", group = "layout"}),
	        
    awful.key({ altkey, "Control", "Shift" }, "Left",
	    function ()
	        -- get current tag
	        local t = client.focus and client.focus.first_tag or nil
	        if t == nil then
	            return
	        end
	        -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
	        local tag = client.focus.screen.tags[(t.name - 2) % 9 + 1]
            client.focus:move_to_tag(tag)
	    end,
	        {description = "move client to previous tag", group = "layout"}),
	awful.key({ altkey, "Control", "Shift" }, "Right",
	    function ()
	        -- get curreìnt tag
	        local t = client.focus and client.focus.first_tag or nil
	        if t == nil then
	            return
	        end
	        -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
	        local tag = client.focus.screen.tags[(t.name % 9) + 1]
	        client.focus:move_to_tag(tag)
	    end,
	        {description = "move client to next tag", group = "layout"}),
	
	-- Toggle client to prev/next tag
		awful.key({ modkey, altkey, "Shift" }, "Left",
		    function ()
		    	-- get current tag
   		        local t = awful.screen.focused().selected_tag or nil
   		        if t == nil then
   		            return
   		        end
		        -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
		        local tag = client.focus.screen.tags[(t.name - 2) % 9 + 1]
				client.focus:toggle_tag(tag)
		        -- tag:view_only()
		    end,
		        {description = "toggle focused client to previous tag", group = "layout"}),
		awful.key({ modkey, altkey, "Shift" }, "Right",
		    function ()
		        -- get current tag
		        local t = awful.screen.focused().selected_tag or nil
		        if t == nil then
		            return
		        end
		        -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
		        local tag = client.focus.screen.tags[(t.name % 9) + 1]
		        client.focus:toggle_tag(tag)
		        -- tag:view_only()
		    end,
		        {description = "toggle focused client to next tag", group = "layout"}),
	
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
                
    awful.key({ altkey }, "Escape",      require("awful.hotkeys_popup").show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
   
    -- Layout manipulation
    awful.key({ altkey, "Control" }, "Right", function () awful.screen.focus_relative( 1) end,
              {description = "change screen focus", group = "screen"}),
	awful.key({ altkey, "Control" }, "Left",  function () awful.screen.focus_relative(-1) end,
              {description = "change screen focus", group = "screen"}),
              
    awful.key({ modkey, "Control" }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    
    awful.key({ altkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    
    awful.key({ modkey,           }, "Return" , function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    -- awful.key({ modkey, altkey    }, "Return", function () handy([[xfce4-terminal]], awful.placement.centered, 0.6, 0.7) end,
              -- {description = "open a scrathpad terminal", group = "launcher"}),
              
    -- WIP 
    -- awful.key({ modkey, altkey    }, "Return", function () 
    --         awful.spawn.raise_or_spawn([[xterm -xrm 'XTerm*allowTitleOps: false' -T scratchpad]], {role="scratchpad", skip_taskbar=true, floating=true, ontop=true, sticky=true}, function(c) 
    --             if c.name == "scratchpad" then
    --                 if client.focus == c then
    --                     c.hidden = true
    --                     c.minimized = false
    --                 else
    --                     client.focus = c 
    --                     c.hidden = false
    --                     c.minimized = true
    --                 end
    --                 return true 
    --             end 
    --                 return false 
    --             end) end,
    --           {description = "open a dropdown terminal", group = "launcher"}),
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
                local clients = awful.screen.focused().selected_tag:clients()
                
                for i = #clients, 1, -1 do
                    if clients[i].minimized then
                        clients[i]:emit_signal("request::activate", "key.unminimize", {raise = true})
                        break
                    end
                end
            end,
            {description = "restore minimized", group = "client"}),

    -- Launchers
	awful.key({ modkey },            "o",     function () awful.spawn([[rofi -modi suit-settings -show suit-settings -theme settings]]) end,
		    {description = "show windows (all desktops)", group = "launcher"}),
		    
	awful.key({ modkey },            "a",     function () awful.spawn([[rofi -modi window -show window -selected-row 0]]) end,
			{description = "show windows (all desktops)", group = "launcher"}),
		
	awful.key({ modkey },            "b",     function () awful.spawn([[rofi-bluetooth]]) end,
				{description = "bluetooth", group = "launcher"}),
	
	awful.key({ modkey },            "k",     function () awful.spawn([[rofi -modi calc -show calc -no-show-match -no-sort]]) end,
			{description = "calculator", group = "launcher"}),
			
	awful.key({ modkey },            "c",     function () awful.spawn.with_shell([[clipmenu -p  && xdotool key shift+Insert]]) end,
			{description = "clipboard", group = "launcher"}),
			
    -- awful.key({ modkey, "Control" }, "c",     function () awful.spawn.with_shell("clipmenu -theme clipdel -p  && clipdel -d $(xsel -o)") end,
    awful.key({ modkey, "Control" }, "c",     function () awful.spawn.with_shell([[rofi -modi suit-delclip -show suit-delclip -theme clipdel -p ]]) end,
    		{description = "Delete clipboard entries", group = "launcher"}),
			
	awful.key({ modkey },            "d",     function () awful.spawn([[rofi -modi drun -show drun -theme grid -selected-row 0]]) end,
	        {description = "open applications", group = "launcher"}),
	
	awful.key({ modkey },            "e",     function () awful.spawn.with_shell([[clipctl disable; rofi -modi emoji -show emoji -emoji-format {emoji} -theme emoji -kb-custom-1 Ctrl+c -selected-row 0 ; clipctl enable]], false) end,
			{description = "emoji picker", group = "launcher"}),              
			
	awful.key({ modkey },            "g",     function () awful.spawn([[rofi -modi filebrowser -show filebrowser]]) end,
			{description = "file browser", group = "launcher"}),
	              		              
	awful.key({ modkey },            "m",     function () awful.spawn([[udiskie-dmenu -matching regex -dmenu -i -no-custom -multi-select -p ]]) end,
			{description = "Mount devices", group = "launcher"}),
		 	
	awful.key({ modkey ,         },  "n",     function () awful.spawn([[networkmanager_dmenu]]) end,
            {description = "network launcher", group = "launcher"}),
                		 	
    awful.key({ modkey },  "p",     function () awful.spawn([[suit-monitor]]) end,
            {description = "Display Mode", group = "launcher"}),        
			
	awful.key({ modkey , "Shift" },  "q",     function () awful.spawn([[rofi -modi suit-powermenu -show suit-powermenu -theme power -selected-row 0]]) end,
		 	{description = "Power menu", group = "launcher"}),
	              		              	              	              		              	             
	-- awful.key({ modkey },            "s",     function () awful.spawn.with_shell('xdg-open "$(plocate -i --regex "$HOME/[^.]" | rofi -dmenu -i -keep-right -p  -auto-select)"') end,
	-- awful.key({ modkey },            "s",     function () awful.spawn.with_shell('xdg-open "$(plocate -d "$HOME/.cache/plocate.db" -i --regex "$HOME/[^.]" | rofi -dmenu -i -keep-right -p  -auto-select)" || updatedb -l 0 -U "$HOME" "$HOME/.config" "$HOME/.local" "$HOME/.cache" "$HOME/Games" -o "$HOME/.cache/plocate.db"') end,
	-- awful.key({ modkey },            "s",     function () awful.spawn.with_shell('xdg-open "$(fd . -c never | rofi -dmenu -i -keep-right -p )"') end, -- -theme-str "element-icon {enabled: false;}"
	awful.key({ modkey },            "s",     function () awful.spawn([[rofi -modi suit-search -show suit-search -theme-str 'element-icon {enabled: false;}' -kb-accept-alt '' -kb-custom-1 'Shift+Return' -kb-custom-2 'Alt+Return' -disable-history -no-sort -keep-right -selected-row 0]]) end,
	        {description = "File searcher", group = "launcher"}),
	awful.key({ modkey },            "w",     function () awful.spawn.with_shell([[rofi -modi windowcd -show windowcd -selected-row 0]]) end,
		    {description = "show windows (current desktop)", group = "launcher"}),
		              
	awful.key({ modkey },         "Escape",     function () awful.spawn.with_shell([[seltr auto pt-BR]]) end,
			{description = "Translate selected text", group = "launcher"}),
			
	-- Apps
	awful.key({ modkey , "Shift" },  "b",     function () awful.spawn(terminal .. " -e btop") end,
				 {description = "btop", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "c",     function () awful.spawn(terminal .. " -e micro") end,
				 {description = "micro text editor", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "d", function () awful.spawn([[rofi -modi suit-wallpaper -show suit-wallpaper -theme wallpaper]]) end,
				 {description = "wallpaper", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "f",     function () awful.spawn(terminal .. " -e ranger") end,
				 {description = "ranger file manager", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "h",     function () awful.spawn(terminal .. " -e htop") end,
				 {description = "htop", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "n",     function () awful.spawn(terminal .. " -e nmtui", {floating = true}) end,
				 {description = "network manager", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "s",     function () 
	        awful.spawn.raise_or_spawn(terminal .. " -e ncspot", nil, function(c)
				if c.name == "ncspot" then
					c:jump_to()
					return true
				end
				return false
			end) 
		end, {description = "ncspot", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "v",     function () awful.spawn([[code]]) end,
				 {description = "vs code", group = "launcher"}),
	awful.key({ modkey , "Shift" },  "w",     function () awful.spawn([[firefox]]) end,
				 {description = "web browser", group = "launcher"}),
	awful.key({ altkey , "Shift" },  "w",     function () awful.spawn([[firefox --private-window]]) end),

	-- Lockscreen
    awful.key({ modkey },            "l",     function () awful.spawn([[suit-lockscreen]]) end,
        {description = "Lock Screen", group = "launcher"}),
        
    -- Bright Keys
    awful.key({}, "XF86MonBrightnessUp", function() backlight("A") end),
    awful.key({}, "XF86MonBrightnessDown", function() backlight("U") end),
              
	-- Volume Keys
    awful.key({}, "XF86AudioRaiseVolume", function() suitAUDIO:volume("+") end),
    awful.key({}, "XF86AudioLowerVolume", function() suitAUDIO:volume("-") end),
    awful.key({}, "XF86AudioMute", function() suitAUDIO:mute() end),
    
	-- Media Keys	
    awful.key({}, "XF86AudioPlay", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any play-pause")
    end),    
    awful.key({modkey}, "/", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any play-pause")
    end),
    
    awful.key({}, "XF86AudioNext", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any next")
    end),
    awful.key({modkey}, ".", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any next")
    end),
    
    awful.key({}, "XF86AudioPrev", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any previous")
    end),
    awful.key({modkey}, ",", function()
        awful.spawn("playerctl --player=spotify,ncspot,%any previous")
    end),
	   
	-- Screenshot
    awful.key({}, "Print", function ()
        local name = beautiful.picture_dir .. os.date("/Screenshots/Screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.easy_async([[maim ]] .. name, function()
            naughty.notify({ title = "Screenshot captured",
				             text  = name,
        			     	 icon  = "preferences-desktop-wallpaper",
        			     	 run   = function() awful.spawn('xdg-open ' .. name) end })
        end) 
    end, {description = "Print desktop", group = "Screenshot"}),
    
    awful.key({ modkey }, "Print", function ()
        local name = beautiful.picture_dir .. os.date("/Screenshots/Screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.easy_async_with_shell([[maim -i $(xdotool getactivewindow) ]] .. name, function()
            naughty.notify({ title = "Screenshot captured",
			    	         text  = name,
        		    	 	 icon  = "preferences-desktop-wallpaper",
        		    	 	 run   = function() awful.spawn('xdg-open ' .. name)  end })
        end)
    end, {description = "Print window", group = "Screenshot"}),
    
    awful.key({ "Shift" }, "Print", nil, function ()
		local name = beautiful.picture_dir .. os.date("/Screenshots/Screenshot_%Y%m%d_%H%M%S.png")
        awful.spawn.easy_async([[maim -s ]] .. name, function(_, _, _, exitcode)            
            if exitcode == 0 then        
                naughty.notify({ title = "Screenshot captured",
    				             text  = name,
            			 	     icon  = "preferences-desktop-wallpaper",
            			 	     run   = function() awful.spawn('xdg-open ' .. name)  end })
            end
        end)
    end, {description = "Print area", group = "Screenshot"}),
    
    awful.key({ "Control" }, "Print", nil, function ()
        awful.spawn.with_shell([[maim -s -k | xclip -selection c -t image/png && notify-send 'Screenshot captured' 'to clipboard' -i 'preferences-desktop-wallpaper']])
    end, {description = "copied to the clipboard", group = "Screenshot"}),
    
    -- ######### TEST ###########
    awful.key({ modkey }, "x", function ()
        awful.spawn.easy_async_with_shell("pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@",
                function(stdout)
                    local volume_level = stdout:match("Volume: front.- (%d+)%%") or "0"
                    local is_muted = stdout:match("Mute: (%a+)") == "yes"
    	            
    	            naughty.notify({title = tostring(is_muted), text = type(is_muted)})
                end)
    end),
    -- ##########################
    
    awful.key({ modkey }, "z", nil, function ()
        awful.spawn.easy_async([[xcolor -s]], function()
            awful.spawn.with_line_callback([[xclip -selection clipboard -o]], {
                stdout = function(color)
                    awful.spawn.easy_async_with_shell('convert $HOME/.local/share/color.png -fill "'.. color .. '" -colorize 100 $HOME/.local/share/color.png', function() 
                        naughty.notify({
                            title = color,
                            text  = "copied to the clipboard",
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
            awful.spawn([[xkill]]) 
    end, {description = "Kill app", group = "client"}),

	awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() 
	end, {description = "run prompt", group = "launcher"})
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

return globalkeys
