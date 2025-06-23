local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local lgi = require("lgi")
local Gio = lgi.Gio
local GLib = lgi.GLib
local icon_theme = lgi.require("Gtk", "3.0").IconTheme.get_default()
local llthreads = require("llthreads2.ex")
local dpi = require("beautiful.xresources").apply_dpi


local index = {row = 1, col = 1}
local all_entries = {}
local page = 1
local refresh = false

local icon_prompt = wibox.widget{
    image = icon_theme:lookup_icon("search", dpi(24), 0):get_filename(),
    resize = false,
    widget = wibox.widget.imagebox,
}

local text_prompt = wibox.widget{
    widget = wibox.widget.textbox
}

local apps_grid = wibox.widget{
    orientation = "vertical",
    homogeneous = true,
    expand = true,
    forced_num_rows = 4,
    forced_num_cols = 6,
    max_n_apps = 4 * 6,
    layout = wibox.layout.grid
}

local launcher_popup = awful.popup{
    widget = {
        {
            {
                icon_prompt,
                text_prompt,
                --
                spacing = dpi(9),
                layout = wibox.layout.fixed.horizontal
            },
            margins = dpi(9),
            widget = wibox.container.margin
        },
        {
            orientation = "horizontal", color = beautiful.bg_minimize, opacity = 0.7, forced_height = dpi(1), forced_width = dpi(1),
            widget = wibox.widget.separator
        },
        {
            apps_grid,
            --
            margins = dpi(9),
            widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.vertical
    },
    border_color = beautiful.border_focus,
    border_width = beautiful.border_width,
    ontop = true,
    visible = false,
    x = 0,
    y = 0,
    minimum_width = dpi(720),
    minimum_height= dpi(529)
}

local function new_app(app, icon)
    local widget = wibox.widget{
        {
            {
                {
                    {
                        -- id = "icon_id",
                        image = icon,
                        resize = true,
                        forced_width = dpi(48),
                        forced_height = dpi(48),
                        widget = wibox.widget.imagebox
                    },
                    widget = wibox.container.place
                },
                {
                    -- id = "name_id",
                    text = app:get_name(),
                    ellipsize = "start",
                    align = "center",
                    widget = wibox.widget.textbox
                },
                spacing = dpi(9),
                layout = wibox.layout.fixed.vertical
            },
            left = dpi(6),
            right = dpi(6),
            top = dpi(15),
            bottom = dpi(1),
            widget  = wibox.container.margin
        },
        shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,7) end,
        bg = beautiful.bg_normal,
        forced_height = dpi(117),
        forced_width = dpi(117),
        widget = wibox.container.background
    }
    
    widget.app = app
    
    widget:connect_signal("mouse::enter", function(a)
        apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.normal)
        a:set_bg(beautiful.bg_focus)
        --update index
        local position = apps_grid:get_widget_position(a)
        if position then
            index.row, index.col = position.row, position.col
        end
    end)

    widget:buttons(gears.table.join(
        awful.button({ }, 1, function ()
            apps_grid:get_widgets_at(index.row, index.col)[1].app:launch()
            launcher_popup.visible = false
        end)
    ))
    
    return widget
end

local function move_up()
    index.row = index.row - 1
    if not apps_grid:get_widgets_at(index.row, index.col) then
        index.row = index.row + 1
    else
        apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
        apps_grid:get_widgets_at(index.row + 1, index.col)[1]:set_bg(beautiful.bg_normal)
    end
end

local function move_down()
    index.row = index.row + 1
    if not apps_grid:get_widgets_at(index.row, index.col) then
        index.row = index.row - 1
    else
        apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
        apps_grid:get_widgets_at(index.row - 1, index.col)[1]:set_bg(beautiful.bg_normal)
    end
end

local function move_left()
    index.col = index.col - 1
    if not apps_grid:get_widgets_at(index.row, index.col) then
        index.col = index.col + 1
    else
        apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
        apps_grid:get_widgets_at(index.row, index.col + 1)[1]:set_bg(beautiful.bg_normal)
    end
end

local function move_right()
    index.col = index.col + 1
    if not apps_grid:get_widgets_at(index.row, index.col) then
        index.col = index.col - 1
    else
        apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
        apps_grid:get_widgets_at(index.row, index.col - 1)[1]:set_bg(beautiful.bg_normal)
    end
end

local function next_page()
    page = page + 1
    if page > 0 and page <= math.ceil(#all_entries / apps_grid.max_n_apps) then
        apps_grid:reset()
        for i = apps_grid.max_n_apps * page - apps_grid.max_n_apps + 1, math.min(apps_grid.max_n_apps * page, #all_entries) do
            apps_grid:add(new_app(all_entries[i].app_info, all_entries[i].app_icon))
        end
        if not apps_grid:get_widgets_at(index.row, index.col) then
            local apps = apps_grid:get_children()
            local app = apps_grid:get_widget_position(apps[#apps])
            index.row, index.col = app.row, app.col
        end
        apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
    else
        page = page - 1
    end
end

local function prev_page()
    page = page - 1
    if page > 0 and page <= math.ceil(#all_entries / apps_grid.max_n_apps) then
        apps_grid:reset()
        for i = apps_grid.max_n_apps * page - apps_grid.max_n_apps + 1, math.min(apps_grid.max_n_apps * page, #all_entries) do
            apps_grid:add(new_app(all_entries[i].app_info, all_entries[i].app_icon))
        end
        if not apps_grid:get_widgets_at(index.row, index.col) then
            local apps = apps_grid:get_children()
            local app = apps_grid:get_widget_position(apps[#apps])
            index.row, index.col = app.row, app.col
        end
        apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
    else
        page = page + 1
    end
end

local function home_page()
    page = 1
    apps_grid:reset()
    for i = apps_grid.max_n_apps * page - apps_grid.max_n_apps + 1, math.min(apps_grid.max_n_apps * page, #all_entries) do
        apps_grid:add(new_app(all_entries[i].app_info, all_entries[i].app_icon))
    end
    local apps = apps_grid:get_children()
    local app = apps_grid:get_widget_position(apps[1])
    index.row, index.col = app.row, app.col
    apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
end

local function end_page()
    page = math.ceil(#all_entries / apps_grid.max_n_apps)
    apps_grid:reset()
    for i = apps_grid.max_n_apps * page - apps_grid.max_n_apps + 1, math.min(apps_grid.max_n_apps * page, #all_entries) do
        apps_grid:add(new_app(all_entries[i].app_info, all_entries[i].app_icon))
    end
    local apps = apps_grid:get_children()
    local app = apps_grid:get_widget_position(apps[#apps])
    index.row, index.col = app.row, app.col
    apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
end

icon_prompt:buttons(
    awful.button({ }, 1, function () launcher_popup.visible = false end)
)

icon_prompt:connect_signal("mouse::enter", function()
    icon_prompt.image = icon_theme:lookup_icon("gtk-quit", dpi(24), 0):get_filename()
end)

icon_prompt:connect_signal("mouse::leave", function()
    icon_prompt.image = icon_theme:lookup_icon("search", dpi(24), 0):get_filename()
end)

apps_grid:buttons(gears.table.join(
    awful.button({ }, 4, prev_page),
    awful.button({ }, 5, next_page)
))

local function tag_view_empty(direction)
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

        if #tags[i]:clients() == 0 then
            tags[i]:view_only()
            return
        end
    until (i == selected_tag_index)
end

launcher_popup.hide = function ()
    launcher_popup.visible = false
end

launcher_popup.toggle = function ()
    launcher_popup.screen = awful.screen.focused()
    awful.placement.centered(launcher_popup)
    launcher_popup.visible = not launcher_popup.visible
end

launcher_popup.update = function()
    GLib.idle_add(GLib.PRIORITY_LOW, function()
        all_entries = {}
        for _, entry in ipairs(Gio.AppInfo.get_all()) do
            if entry:should_show() then
                table.insert(all_entries, {app_info = entry, app_icon = icon_theme:lookup_icon(entry:get_icon():to_string(), dpi(48), 0):get_filename()})
            end
        end
        -- table.sort(all_entries, function (a, b) return a.app_info:get_name():lower() < b.app_info:get_name():lower() end)
    end)
end

--launcher_popup.update = function()
--    local function get_desktop_entries()
--        local lgi = require("lgi")
--        local Gio = lgi.Gio
--        local IconTheme = lgi.require("Gtk", "3.0").IconTheme.get_default()
--
--        local all_entries = {}
--        for _, entry in ipairs(Gio.AppInfo.get_all()) do
--            if entry:should_show() then
--                table.insert(all_entries, {app_info = entry, app_icon = IconTheme:lookup_icon(entry:get_icon():to_string(), 48, 0):get_filename()})
--            end
--        end
--
--        -- Callback to join on main thread
--        -- os.execute([[awesome-client 'awesome:emit_signal("launcher::updated")']])
--
--        return all_entries
--    end
--
--    -- Criando uma thread
--    thread_desktop_entries = llthreads.new(get_desktop_entries)
--    -- Iniciando a thread
--    thread_desktop_entries:start()
--    -- Thread callback
--    _, all_entries = thread_desktop_entries:join()
--end

-- awesome.connect_signal("launcher::updated", function ()
--     if thread_desktop_entries then
--         _, all_entries = thread_desktop_entries:join()
--     end
-- end)

launcher_popup.populate = function ()
    for i = 1, math.min(#all_entries, apps_grid.max_n_apps) do
        apps_grid:add(new_app(all_entries[i].app_info, all_entries[i].app_icon))
    end
    
    index.row, index.col = 1, 1
    page = 1
    apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)
end

local function prompt_run()
    awful.prompt.run{
        prompt = '',
        textbox = text_prompt,
        hooks = {
            {{      }, 'Return', function ()
                if apps_grid:get_widgets_at(index.row, index.col) then
                    apps_grid:get_widgets_at(index.row, index.col)[1].app:launch()
                end
            end},
            {{'Shift'}, 'Return', function()
                if apps_grid:get_widgets_at(index.row, index.col) then
                    tag_view_empty(1)
                    apps_grid:get_widgets_at(index.row, index.col)[1].app:launch()
                end
            end},
            {{'Mod1'}, 'Return', function()
                if apps_grid:get_widgets_at(index.row, index.col) then
                    tag_view_empty(1)
                    apps_grid:get_widgets_at(index.row, index.col)[1].app:launch()
                end 
            end},
            {{      }, 'Escape', function ()
                launcher_popup.visible = false
            end}
        },
        keypressed_callback = function (_, key, _)
            refresh = false
            if key == "Up" then
                move_up()
            elseif key == "Down" then
                move_down()
            elseif key == "Left" then
                move_left()
            elseif key == "Right" then
                move_right()
            elseif key == "Next" then
                next_page()
            elseif key == "Prior" then
                prev_page()
            elseif key == "Home" then
                home_page()
            elseif key == "End" then
                end_page()
            elseif key == "Alt_L" then
                return
            else
                refresh = true
            end
        end,
        changed_callback = function (input)
            if refresh then
                apps_grid:reset()

                local apps_names = {}
                local i = 1
                while i <= #all_entries and #apps_grid:get_children() < apps_grid.max_n_apps do
                    table.insert(apps_names, all_entries[i].app_info:get_name())
                    i = i + 1
                end

                function filter_sort (input, apps_names)
                    local fzy = require("fzy")

                    local results = fzy.filter(input, apps_names)
                    table.sort(results, function (a, b) return a[3] > b[3] end)

                    return results
                end

                local _, results = llthreads.new(filter_sort, input, apps_names):start():join()

                local i = 1
                while i <= #results and #apps_grid:get_children() < apps_grid.max_n_apps do
                    apps_grid:add(new_app(all_entries[results[i][1]].app_info, all_entries[results[i][1]].app_icon))
                    i = i + 1
                end

                if #apps_grid:get_children() > 0 then
                    index.col, index.row = 1, 1
                    apps_grid:get_widgets_at(index.row, index.col)[1]:set_bg(beautiful.bg_focus)    
                end
            end
        end,
        done_callback = function ()
            launcher_popup.visible = false
        end
    }
end

launcher_popup:connect_signal("property::visible", function (self)
    if self.visible then
        prompt_run()
        self.populate()
        client.connect_signal("button::press", self.hide)
        awesome.connect_signal("button::press", self.hide)
    else
        awful.keygrabber.stop()
        apps_grid:reset()
        client.disconnect_signal("button::press", self.hide)
        awesome.disconnect_signal("button::press", self.hide)
        -- collectgarbage()
    end
end)

local launcher_icon = wibox.widget {
    image  = ".config/awesome/themes/nord-pink/suit-logo.png",
    resize = false,
    widget = wibox.widget.imagebox
}

launcher_icon:buttons(
    awful.button({ }, 1, function ()
        local placement_next_to_corner = awful.placement.under_mouse + awful.placement.closest_corner
        placement_next_to_corner(launcher_popup, {honor_workarea = true, margins = dpi(14)})
        launcher_popup.visible = not launcher_popup.visible
    end)
)

launcher_icon.hide = function ()
    launcher_popup:hide()
end

launcher_popup.update()
GAppInfoMonitor = Gio.AppInfoMonitor:get()
GAppInfoMonitor.on_changed = launcher_popup.update

return setmetatable({}, {
    __index = launcher_icon,
	__call = launcher_popup.toggle
})
