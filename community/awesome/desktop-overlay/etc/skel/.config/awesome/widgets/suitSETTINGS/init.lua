local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local dpi = require("beautiful.xresources").apply_dpi
local icon_theme = require("lgi").require("Gtk", "3.0").IconTheme.get_default()


local index = 1
local all_entries = {}
local filtered_entries = {}
local max_rows = {[false] = 23, [true] = 22}
local refresh = false

local icon_prompt = wibox.widget {
    image = icon_theme:lookup_icon("fcitx-mozc-properties", dpi(16), 0):get_filename(),
    resize = false,
    forced_width = dpi(17),
    forced_height = dpi(17),
    widget = wibox.widget.imagebox
}

local prompt = awful.widget.prompt {
    prompt = '',
    history_path = ''
}

local rows = wibox.widget {
    layout  = wibox.layout.flex.vertical
}

local header = wibox.widget {
    {
        {
            {
                {
                    id = "title_id",
                    align  = "center",
                    valign = "center",
                    font = "Noto Sans Medium 14",
                    widget = wibox.widget.textbox
                },
                {
                    id = "subtitle_id",
                    align  = "center",
                    valign = "center",
                    font = "Noto Sans Medium 9",
                    widget = wibox.widget.textbox
                },
                layout = wibox.layout.fixed.vertical
            },
            margins = dpi(12),
            widget  = wibox.container.margin
        },
        bg = "#2c3038",
        widget = wibox.container.background
    },
    {
        orientation = "horizontal", color = beautiful.bg_minimize, opacity = 0.7, forced_height = dpi(1), forced_width = dpi(1),
        widget = wibox.widget.separator
    },
    visible = false,
    layout = wibox.layout.fixed.vertical
}

function header:set(title, subtitle)
    self:get_children_by_id("title_id")[1]:set_markup(string.format("<span foreground='#FAFAFA'>%s</span>", title))
    self:get_children_by_id("subtitle_id")[1]:set_markup(string.format("<span foreground='#D1D1D1'>%s</span>", subtitle))
end

local settings_popup = awful.popup {
    widget = {
        {
            orientation = 'vertical', color = beautiful.border_focus, thickness = beautiful.border_width, forced_height = beautiful.border_width, forced_width = beautiful.border_width,
            widget = wibox.widget.separator
        },
        {
            {
                {
                    {
                        icon_prompt,
                        halign = "center",
                        valign = "center",
                        widget = wibox.container.place
                    },
                    prompt.widget,
                    -- 
                    spacing = dpi(12),
                    layout = wibox.layout.fixed.horizontal
                },
                margins = dpi(12),
                widget = wibox.container.margin
            },
            {
                orientation = "horizontal", color = beautiful.bg_minimize, opacity = 0.7, forced_height = dpi(1), forced_width = dpi(1),
                widget = wibox.widget.separator
            },
            header,
            rows,
            layout = wibox.layout.fixed.vertical
        },
        layout = wibox.layout.align.horizontal
    },
    border_width = 0,
    ontop = true,
    visible = false,
    type = "toolbar",
    minimum_height = awful.screen.focused().geometry.height,
    maximum_height = awful.screen.focused().geometry.height,
    minimum_width = dpi(378),
    maximum_width = dpi(378),
    placement = awful.placement.right
}

local function new_row(entry)
    if entry.is_separator then
        local row = wibox.widget {
            {
                {
                    text = " ",
                    widget = wibox.widget.textbox
                },
                margins = dpi(12),
                widget  = wibox.container.margin
            },
            bg = beautiful.bg_normal,
            widget = wibox.container.background
        }

        row.is_separator = true

        row.get_text = function ()
            return ""
        end

        return row
    end

    local row = wibox.widget {
        {
            {
                entry.image and {
                    {
                        -- id = "icon_id",
                        image = icon_theme:lookup_icon(entry.image, dpi(16), 0):get_filename(),
                        resize = false,
                        forced_width = dpi(17),
                        forced_height = dpi(17),
                        widget = wibox.widget.imagebox
                    },
                    widget = wibox.container.place
                },
                {
                    -- id = "text_id",
                    text = entry.text,
                    ellipsize = "start",
                    align  = "left",
                    widget = wibox.widget.textbox
                },
                entry.info and {
                    markup = string.format("<span foreground='#c7c7c7'>%s</span>", entry.info),
                    align  = "right",
                    widget = wibox.widget.textbox
                },
                spacing = dpi(12),
                fill_space = true,
                layout = wibox.layout.fixed.horizontal
            },
            margins = dpi(12),
            widget  = wibox.container.margin
        },
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }

    row.action = entry.action

    row.set_image = function(self, image) 
        self.widget.widget.children[1].image = image
    end
    
    row.get_text = function(self)
        return self.widget.widget.children[2].text
        -- return self:get_children_by_id("text_id")[1].text
    end
    
    row:connect_signal("mouse::enter", function(row)
        rows.children[index]:set_bg(beautiful.bg_normal)
        row:set_bg(beautiful.bg_focus)
        index = rows:index(row, false)
    end)
    
    row:buttons(
        awful.button({ }, 1, function ()
            prompt.keypressed_callback(_, "Return")
        end)
    )

    return row
end

icon_prompt:connect_signal("mouse::enter", function ()
    icon_prompt.image = icon_theme:lookup_icon("gtk-quit", dpi(16), 0):get_filename()
end)

icon_prompt:connect_signal("mouse::leave", function ()
    icon_prompt.image = icon_theme:lookup_icon("fcitx-mozc-properties", dpi(16), 0):get_filename()
end)

icon_prompt:buttons(
    awful.button({ }, 1, function () settings_popup.visible = false end)
)

settings_popup.toggle = function (self)
    self.visible = not self.visible
end

settings_popup.hide = function ()
    settings_popup.visible = false
end

local function scroll_down()
    if #filtered_entries > #rows.children then
        for i = 1, #filtered_entries - 1 do
            if rows.children[#rows.children]:get_text() == filtered_entries[i].text then
                rows.children[1] = nil
                rows:remove(1)
                rows:add(new_row(filtered_entries[i+1]))
                break
            end
        end
    end
end

local function scroll_up()
    if #filtered_entries > #rows.children then
        for i = #filtered_entries, 2, -1 do
            if rows.children[1]:get_text() == filtered_entries[i].text then
                rows:insert(1, new_row(filtered_entries[i-1]))
                rows:remove(#rows.children)
                break
            end
        end
    end
end

local function scroll_home()
    rows:reset()
    for i = 1, math.min(#all_entries, #rows.children) do
        rows:add(new_row(all_entries[i]))
    end
end

local function scroll_end(n_rows)
    rows:reset()
    for i = #all_entries - n_rows + 1, #all_entries do
        rows:add(new_row(all_entries[i]))
    end
end

rows:buttons(gears.table.join(
    awful.button({ }, 4, function ()
        if #filtered_entries > #rows.children then
            for i = #filtered_entries, 2, -1 do
                if rows.children[1]:get_text() == filtered_entries[i].text then
                    rows:remove(#rows.children)
                    rows:insert(1, new_row(filtered_entries[i - 1]))
                    rows.children[index]:set_bg(beautiful.bg_focus)
                    if rows.children[index + 1] then
                        rows.children[index + 1]:set_bg(beautiful.bg_normal)
                    end
                    break
                end
            end
        end
    end),
    awful.button({ }, 5, function ()
        if #filtered_entries > #rows.children then
            for i = 1, #filtered_entries - 1 do
                if rows.children[#rows.children]:get_text() == filtered_entries[i].text then
                    rows:remove(1)
                    rows:add(new_row(filtered_entries[i + 1]))
                    rows.children[index]:set_bg(beautiful.bg_focus)
                    if rows.children[index - 1] then
                        rows.children[index - 1]:set_bg(beautiful.bg_normal)
                    end
                    break
                end
            end
        end
    end)
))

local function populate(new_index, title, subtitle)
    header:set(title, subtitle)
    if title then
        header.visible = true
    else
        header.visible = false
    end
    
    rows:reset() 
    for i = 1, math.min(#all_entries, max_rows[header.visible]) do
        rows:add(new_row(all_entries[i]))
    end
    
    filtered_entries = all_entries
    
    index = rows.children[new_index] and new_index or 1
    rows.children[index]:set_bg(beautiful.bg_focus)    
end

local function iterator2table(iterator)
    local array = {}
    for element in iterator:gmatch("[^\n]+") do
        array[#array+1] = element
    end
    return array
end

function screen_resolution_menu(screen)
    awful.spawn.easy_async({"sh", "-c", "xrandr | awk '{ print $1 }'"}, function(output)
        all_entries = {}
        output = iterator2table(output)

        table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = screen_menu})
        for i=1, #output do
            if output[i] == screen then
                for i = i + 1, #output do
                    if string.find(output[i], "x") then
                        table.insert(all_entries, {text = output[i], image = "video-display", action = function ()
                            awful.key.execute({}, "Escape")
                            awful.spawn("xrandr -s " .. output[i])
                        end})
                    end
                end
                break
            end
        end
        populate()
    end)
end

function screen_menu()
    awful.spawn.easy_async({"sh", "-c", [[xrandr | awk '$2=="connected" { print $1 }']]}, function(screens)
        all_entries = {}
        for screen in screens:gmatch("[^\n]+") do
            table.insert(all_entries, {text = screen, image = "video-display", action = function()
                screen_resolution_menu(screen)
            end})
        end        
        table.insert(all_entries, {text = "", is_separator = true})
        table.insert(all_entries, {text = "Back", image = "edit-clear", action = main_menu})
        populate()
    end)
end

function power_menu()
    awful.spawn.easy_async({"sh", "-c", "tlp-stat --mode"}, function(mode)
        all_entries = {}
        if mode:find("AC") and true or false then
            table.insert(all_entries, {text = "Power saving mode", image = "view-calendar", action = function()
                -- rows.children[1]:set_image(iconTheme:lookup_icon("view-calendar-special-occasion", dpi(16), 0):get_filename()) -- TODO
                awful.spawn.easy_async("sudo tlp bat", function() power_menu() end)
            end})
        else
            table.insert(all_entries, {text = "Power saving mode", image = "view-calendar-special-occasion", action = function()
                -- rows.children[1]:set_image(iconTheme:lookup_icon("view-calendar", dpi(16), 0):get_filename()) -- TODO
                awful.spawn.easy_async("sudo tlp ac", function() power_menu() end)
            end})
        end
        table.insert(all_entries, {text = "", is_separator = true})
        table.insert(all_entries, {text = "Back", image = "edit-clear", action = main_menu})
        populate()
    end)
end

local function time_date_status_menu()
    awful.spawn.easy_async({"sh", "-c", "timedatectl status | sed 's/^ *//g'"}, function (output)
        all_entries = {}
        for line in output:gmatch("[^\n]+") do
            table.insert(all_entries, {text = line})
        end
        table.insert(all_entries, {text = "", is_separator = true})
        table.insert(all_entries, {text = "Back", image = "go-previous", action = time_date_menu})
        populate()
    end)
end

local function set_time_zone(timezone)
    awful.key.execute({}, "Escape")
    awful.spawn("timedatectl set-timezone " .. timezone)
end

local function time_zone_menu()
    awful.spawn.easy_async({ "sh", "-c", "timedatectl status --no-pager | grep 'Time zone' | awk '{print $3}'"}, function (current_timezone)
        current_timezone = current_timezone:gsub("\n", "")
        awful.spawn.easy_async({"sh", "-c", "timedatectl list-timezones --no-pager"}, function (timezones)
            all_entries = {}
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = time_date_menu})
            for timezone in timezones:gmatch("[^\n]+") do
                if current_timezone == timezone then
                    -- table.insert(all_entries, {text = timezone, image = "network-connect", action = function () set_time_zone(timezone) end})
                    table.insert(all_entries, {text = timezone, image = "fcitx-fullwidth-active", action = function () set_time_zone(timezone) end})
                else
                    -- table.insert(all_entries, {text = timezone, image = "network-disconnect", action = function () set_time_zone(timezone) end})
                    table.insert(all_entries, {text = timezone, image = "fcitx-fullwidth-inactive", action = function () set_time_zone(timezone) end})
                end
            end
            populate(_, "Time zone", "America/Fortaleza")
        end)
    end)
end

local function time_year_manually_menu(time)
    all_entries = {}
    table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = function () time_manually_menu(time) end})
    for i = 1900, 2100 do
        table.insert(all_entries, {text = tostring(i), action = function ()
            time.year = i
            time_manually_menu(time)
        end})
    end
    populate()
end

local function time_month_manually_menu(time)
    all_entries = {}
    table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = function () time_manually_menu(time) end})
    for i = 1, 12 do
        table.insert(all_entries, {text = tostring(i), action = function ()
            time.month = i
            time_manually_menu(time)
        end})
    end
    populate()
end

local function time_day_manually_menu(time)
    all_entries = {}
    table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = function () time_manually_menu(time) end})
    for i = 1, 31 do
        table.insert(all_entries, {text = tostring(i), action = function ()
            time.day = i
            time_manually_menu(time)
        end})
    end
    populate()
end

local function time_hour_manually_menu(time)
    all_entries = {}
    table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = function () time_manually_menu(time) end})
    for i = 0, 23 do
        table.insert(all_entries, {text = tostring(i), action = function ()
            time.hour = i
            time_manually_menu(time)
        end})
    end
    populate()
end

local function time_minute_manually_menu(time)
    all_entries = {}
    table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = function () time_manually_menu(time) end})
    for i = 0, 59 do
        table.insert(all_entries, {text = tostring(i), action = function ()
            time.minute = i
            time_manually_menu(time)
        end})
    end
    populate()
end

local function time_second_manually_menu(time)
    all_entries = {}
    table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = function () time_manually_menu(time) end})
    for i = 0, 59 do
        table.insert(all_entries, {text = tostring(i), action = function ()
            time.second = i
            time_manually_menu(time)
        end})
    end
    populate()
end

local function set_time_automatically_menu(is_inactive)
    awful.key.execute({}, "Escape")
    awful.spawn("timedatectl set-ntp " .. tostring(is_inactive))
end

local function set_time_manually_menu(time)
    if time.year and time.month and time.day and time.hour and time.minute and time.second then
        awful.key.execute({}, "Escape")
        awful.spawn.with_shell(string.format("timedatectl set-ntp false && timedatectl set-time '%04d-%02d-%02d %02d:%02d:%02d'", time.year, time.month, time.day, time.hour, time.minute, time.second))
    end
end



function time_manually_menu(time)
    local time = time or {}

    all_entries = {
        {text = "Year", info = time.year, action = function () time_year_manually_menu(time) end},
        {text = "Month", info = time.month, action = function () time_month_manually_menu(time) end},
        {text = "Day", info = time.day, action = function () time_day_manually_menu(time) end},
        {text = "Hour", info = time.hour, action = function () time_hour_manually_menu(time) end},
        {text = "Minute", info = time.minute, action = function () time_minute_manually_menu(time) end},
        {text = "Second", info = time.second, action = function () time_second_manually_menu(time) end},
        {text = "", is_separator = true},
        {text = "Apply", image = "object-select", action = function () set_time_manually_menu(time) end},
        {text = "Back", image = "go-previous", action = time_date_menu},
    }
    populate()
end

function time_date_menu()
    awful.spawn.easy_async({ "sh", "-c", "timedatectl -a | awk 'NR==6 { print $3 }'" }, function(output)
        local is_inactive = output:find("inactive") and true or false
        all_entries = {
            {text = "Show Status", image = "help-about", action = time_date_status_menu},
            {text = "Set Time Manually", image = "history", action = time_manually_menu},
            {text = "Set Time Automatically", image = is_inactive and "view-calendar" or "view-calendar-special-occasion", action = function () set_time_automatically_menu(is_inactive) end},
            {text = "Set Time Zone", image = "network", action = time_zone_menu},
            {text = "", is_separator = true},
            {text = "Back", image = "go-previous", action = main_menu},
        }
        populate()
    end)
end

function default_application_selected_advanced_menu(mime)
    awful.spawn.easy_async({"sh", "-c", "xdg-mime query default " .. mime}, function (default)
        awful.spawn.easy_async({"sh", "-c", "grep " .. mime .. " /usr/share/applications/mimeinfo.cache | cut -d = -f 2 | sed 's/.desktop;/\\n/g'| sort | uniq"}, function(apps)
            all_entries = {}
            default = default:gsub(".desktop\n", "")
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_advanced_menu})
            for app in apps:gmatch("[^\n]+") do
                if app == default then
                    table.insert(all_entries, {text = app, image = "starred"})
                else
                    table.insert(all_entries, {text = app, image = "non-starred", action = function ()
                        awful.spawn.easy_async("xdg-mime default " .. app .. ".desktop " .. mime, function()
                            default_application_selected_advanced_menu(mime)
                        end)
                    end})
                end
            end
            populate(index)
        end)
    end)
end

function default_pdf_application()
    awful.spawn.easy_async({"sh", "-c", "xdg-mime query default application/pdf"}, function (default)
        awful.spawn.easy_async({"sh", "-c", "grep application/pdf /usr/share/applications/mimeinfo.cache | cut -d = -f 2 | sed 's/.desktop;/\\n/g'| sort | uniq"}, function(apps)
            all_entries = {}
            default = default:gsub(".desktop\n", "")
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_menu})
            for app in apps:gmatch("[^\n]+") do
                if app == default then
                    table.insert(all_entries, {text = app, image = "starred"})
                else
                    table.insert(all_entries, {text = app, image = "non-starred", action = function ()
                        awful.spawn.easy_async("xdg-mime default " .. app .. ".desktop application/pdf", function()
                            default_pdf_application()
                        end)
                    end})
                end
            end
            populate(index)
        end)
    end)
end

function default_application_advanced_menu()
    awful.spawn.easy_async({"sh", "-c", "tail -n +2 /usr/share/applications/mimeinfo.cache | cut -d = -f 1 | sort | uniq"}, function(output)
        all_entries = {}
        table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_menu})
        for mime in output:gmatch("[^\n]+") do
            table.insert(all_entries, {text = mime, image = "document-edit-sign", action = function ()
                default_application_selected_advanced_menu(mime)
            end})
        end        
        populate()
    end)
end

function default_folder_application_menu()
    awful.spawn.easy_async({"sh", "-c", "xdg-mime query default inode/directory"}, function (default)
        awful.spawn.easy_async({"sh", "-c", "grep inode/directory /usr/share/applications/mimeinfo.cache | cut -d = -f 2 | sed 's/.desktop;/\\n/g'| sort | uniq"}, function(apps)
            all_entries = {}
            default = default:gsub(".desktop\n", "")
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_menu})
            for app in apps:gmatch("[^\n]+") do
                if app == default then
                    table.insert(all_entries, {text = app, image = "starred"})
                else
                    table.insert(all_entries, {text = app, image = "non-starred", action = function ()
                        awful.spawn.easy_async("xdg-mime default " .. app .. ".desktop inode/directory", function()
                            default_folder_application_menu()
                        end)
                    end})
                end
            end
            populate(index)
        end)
    end)
end

function default_mail_application_menu()
    awful.spawn.easy_async({"sh", "-c", "xdg-mime query default x-scheme-handler/mailto"}, function (default)
        awful.spawn.easy_async({"sh", "-c", "grep x-scheme-handler/mailto /usr/share/applications/mimeinfo.cache | cut -d = -f 2 | sed 's/.desktop;/\\n/g'| sort | uniq"}, function(apps)
            all_entries = {}
            default = default:gsub(".desktop\n", "")
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_menu})
            for app in apps:gmatch("[^\n]+") do
                if app == default then
                    table.insert(all_entries, {text = app, image = "starred"})
                else
                    table.insert(all_entries, {text = app, image = "non-starred", action = function ()
                        awful.spawn.easy_async("xdg-mime default " .. app .. ".desktop x-scheme-handler/mailto", function()
                            default_mail_application_menu()
                        end)
                    end})
                end
            end
            populate(index)
        end)
    end)
end

function default_web_application_menu()
    awful.spawn.easy_async({"sh", "-c", "xdg-mime query default x-scheme-handler/https"}, function (default)
        awful.spawn.easy_async({"sh", "-c", "grep x-scheme-handler/https /usr/share/applications/mimeinfo.cache | cut -d = -f 2 | sed 's/.desktop;/\\n/g'| sort | uniq"}, function(apps)
            all_entries = {}
            default = default:gsub(".desktop\n", "")
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_menu})
            for app in apps:gmatch("[^\n]+") do
                if app == default then
                    table.insert(all_entries, {text = app, image = "starred"})
                else
                    table.insert(all_entries, {text = app, image = "non-starred", action = function ()
                        awful.spawn.easy_async("xdg-mime default " .. app .. ".desktop x-scheme-handler/https", function()
                            default_web_application_menu()
                            awful.spawn.with_shell("xdg-mime default " .. app .. ".desktop x-scheme-handler/http")
                        end)
                    end})
                end
            end
            populate(index)
        end)
    end)
end

function default_audio_application_menu()
    awful.spawn.easy_async({"sh", "-c", "xdg-mime query default audio/mp3"}, function (default)
        awful.spawn.easy_async({"sh", "-c", "grep audio/mp3 /usr/share/applications/mimeinfo.cache | cut -d = -f 2 | sed 's/.desktop;/\\n/g'| sort | uniq"}, function(apps)
            all_entries = {}
            default = default:gsub(".desktop\n", "")
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_menu})
            for app in apps:gmatch("[^\n]+") do
                if app == default then
                    table.insert(all_entries, {text = app, image = "starred"})
                else
                    table.insert(all_entries, {text = app, image = "non-starred", action = function ()
                        awful.spawn.easy_async("xdg-mime default " .. app .. ".desktop audio/mp3", function()
                            default_audio_application_menu()
                            awful.spawn.with_shell(
                                "xdg-mime default " .. app .. ".desktop audio/aac ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/ac3 ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/eac3 ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/flac ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/m3u ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/m4a ; " ..
                                -- "xdg-mime default " .. app .. ".desktop audio/mp3 ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/mpeg ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/mpg ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/ogg ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/opus ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/wav ; " ..
                                "xdg-mime default " .. app .. ".desktop audio/webm"
                            )
                        end)
                    end})
                end
            end
            populate(index)
        end)
    end)
end

function default_image_application_menu()
    awful.spawn.easy_async({"sh", "-c", "xdg-mime query default image/png"}, function (default)
        awful.spawn.easy_async({"sh", "-c", "grep image/png /usr/share/applications/mimeinfo.cache | cut -d = -f 2 | sed 's/.desktop;/\\n/g'| sort | uniq"}, function(apps)
            all_entries = {}
            default = default:gsub(".desktop\n", "")
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_menu})
            for app in apps:gmatch("[^\n]+") do
                if app == default then
                    table.insert(all_entries, {text = app, image = "starred"})
                else
                    table.insert(all_entries, {text = app, image = "non-starred", action = function ()
                        awful.spawn.easy_async("xdg-mime default " .. app .. ".desktop image/png", function()
                            default_image_application_menu()
                            awful.spawn.with_shell(
                                "xdg-mime default " .. app .. ".desktop image/avif ; " ..
                                "xdg-mime default " .. app .. ".desktop image/bmp ; " ..
                                "xdg-mime default " .. app .. ".desktop image/gif ; " ..
                                "xdg-mime default " .. app .. ".desktop image/jpeg ; " ..
                                "xdg-mime default " .. app .. ".desktop image/jpg ; " ..
                                "xdg-mime default " .. app .. ".desktop image/pjpeg ; " ..
                                -- "xdg-mime default " .. app .. ".desktop image/png ; " ..
                                "xdg-mime default " .. app .. ".desktop image/svg+xml ; " ..
                                "xdg-mime default " .. app .. ".desktop image/svg+xml-compressed ; " ..
                                "xdg-mime default " .. app .. ".desktop image/tiff ; " ..
                                "xdg-mime default " .. app .. ".desktop image/webp"
                            )
                        end)
                    end})
                end
            end
            populate(index)
        end)
    end)
end

local function default_video_application_menu()
    awful.spawn.easy_async({"sh", "-c", "xdg-mime query default video/mp4"}, function (default)
        awful.spawn.easy_async({"sh", "-c", "grep video/mp4 /usr/share/applications/mimeinfo.cache | cut -d = -f 2 | sed 's/.desktop;/\\n/g'| sort | uniq"}, function(apps)
            all_entries = {}
            default = default:gsub(".desktop\n", "")
            table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = default_application_menu})
            for app in apps:gmatch("[^\n]+") do
                if app == default then
                    table.insert(all_entries, {text = app, image = "starred"})
                else
                    table.insert(all_entries, {text = app, image = "non-starred", action = function ()
                        awful.spawn.easy_async("xdg-mime default " .. app .. ".desktop video/mp4", function()
                            default_video_application_menu()
                            awful.spawn.with_shell(
                                "xdg-mime default " .. app .. ".desktop video/3gp ; " ..
                                "xdg-mime default " .. app .. ".desktop video/avi ; " ..
                                "xdg-mime default " .. app .. ".desktop video/flv ; " ..
                                "xdg-mime default " .. app .. ".desktop video/mkv ; " ..
                                -- "xdg-mime default " .. app .. ".desktop video/mp4 ; " ..
                                "xdg-mime default " .. app .. ".desktop video/mpeg ; " ..
                                "xdg-mime default " .. app .. ".desktop video/ogg ; " ..
                                "xdg-mime default " .. app .. ".desktop video/quicktime ; " ..
                                "xdg-mime default " .. app .. ".desktop video/webm"
                            )
                        end)
                    end})
                end
            end
            populate(index)
        end)
    end)
end

function default_application_menu()
    all_entries = {
        {text = "Web", image = "folder-network", action = default_web_application_menu},
        {text = "Mail", image = "mail-unread", action = default_mail_application_menu},
        {text = "Folder", image = "folder", action = default_folder_application_menu},
        {text = "Audio", image = "folder-music", action = default_audio_application_menu},
        {text = "Image", image = "folder-picture", action = default_image_application_menu},
        {text = "Video", image = "folder-video", action = default_video_application_menu},
        {text = "PDF", image = "folder-documents", action = default_pdf_application},
        {text = "Advanced", image = "configure", action = default_application_advanced_menu},
        {text = "", is_separator = true},
        {text = "Back", image = "go-previous", action = main_menu},
    }
    populate()
end

function test_menu ()
    all_entries = {
        {text = "Test 1", image = "tag", action = main_menu},
        {text = "Test 2", image = "tag", action = main_menu},
        {text = "Test 3", image = "tag", action = main_menu},
        {text = "Test 4", image = "tag", action = main_menu},
        {text = "Test 5", image = "tag", action = main_menu},
        {text = "Test 6", image = "tag", action = main_menu},
        {text = "", is_separator = true},
        {text = "Back", image = "go-previous", action = main_menu}
    }
    populate()
end

function keyboard_menu()
    awful.spawn.easy_async({"sh", "-c", "localectl list-keymaps --no-pager"}, function(keymaps)
        all_entries = {}
        table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = main_menu})
        for keymap in keymaps:gmatch("[^\n]+") do
            -- table.insert(all_entries, {text = keymap, image = "fcitx-vk-active", action = function ()
            table.insert(all_entries, {text = keymap, image = "fcitx-vk-inactive", action = function ()
                awful.key.execute({}, "Escape")
                awful.spawn.with_shell("localectl set-keymap " .. keymap .. " && notify-send -i 'stock_dialog-info' 'Keyboard mapping' 'Session restart is required' || notify-send -i 'dialog-error' 'Keyboard mapping' 'Unable to change your keyboard mapping'")
            end})
        end
        populate(_, "Keyboard", "us-acentos")
    end)
end

function language_menu()
    awful.spawn.easy_async({"sh", "-c", "localectl list-locales --no-pager"}, function(locales)        
        all_entries = {}
        table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = function ()
            header.visible = false
            main_menu()
        end})
        for locale in locales:gmatch("[^\n]+") do
            table.insert(all_entries, {text = locale, image = "languages", action = function ()
                awful.key.execute({}, "Escape")
                awful.spawn.with_shell("localectl set-locale " .. locale .. " && notify-send -i 'stock_dialog-info' 'System Locale' 'Session restart is required' || notify-send -i 'dialog-error' 'System Locale' 'Unable to change your locale'")
            end})
        end
        populate(_, "Language", "PT_BR")
    end)
end

function about_menu()
    awful.spawn.easy_async({"sh", "-c", "neofetch --stdout --separator ' '"}, function(keymaps)
        all_entries = {}
        table.insert(all_entries, {text = "Cancel", image = "edit-clear", action = main_menu})
        for keymap in keymaps:gmatch("[^\n]+") do
            table.insert(all_entries, {text = keymap, image = "keyboard"})
        end
        populate()
    end)
end

function main_menu ()
    all_entries = {
        {text = "Display", image = "video-display", action = screen_menu},
        {text = "Sound", image = "audio-speakers", action = test_menu},
        {text = "Network", image = "network-connect", action = test_menu},
        {text = "Bluetooth", image = "bluetooth", action = test_menu},
        {text = "Power", image = "ac-adapter", action = power_menu},
        {text = "Default Applications", image = "tag", action = default_application_menu},
        {text = "Mouse & Touchpad", image = "input-mouse", action = test_menu},
        {text = "Keyboard", image = "keyboard", action = keyboard_menu},
        {text = "Languages", image = "languages", action = language_menu},
        {text = "Time & Date", image = "history", action = time_date_menu},
        {text = "User", image = "avatar-default", action = test_menu},
        {text = "About", image = "dialog-information", action = about_menu}
    }
    populate()
end

prompt.keypressed_callback = function (_, key)
    if key == "Up" then
        index = index - 1
        if index < 1 then
            index = index + 1
            scroll_up()
        end
        rows.children[index + 1]:set_bg(beautiful.bg_normal)
        if rows.children[index].is_separator then
            prompt.keypressed_callback(_, "Up")
            return
        end
        rows.children[index]:set_bg(beautiful.bg_focus)
    elseif key == "Down" then
        index = index + 1
        if index > #rows.children then
            index = index - 1
            scroll_down()
        end
        rows.children[index - 1]:set_bg(beautiful.bg_normal)
        if rows.children[index].is_separator then
            prompt.keypressed_callback(_, "Down")
            return
        end
        rows.children[index]:set_bg(beautiful.bg_focus)
    elseif key == "Return" or key == "Right" then
        if not rows.children[index] then
            prompt.keypressed_callback("Control", "u") -- Clear the prompt
        elseif rows.children[index].action then
            rows.children[index].action()
        end
    elseif key == "Home" then
        scroll_home()
        index = 1
        if rows.children[index] then
            rows.children[index]:set_bg(beautiful.bg_focus)
        end
    elseif key == "End" then
        index = #rows.children
        scroll_end(index)
        if rows.children[index] then
            rows.children[index]:set_bg(beautiful.bg_focus)
        end
    elseif key == "Escape" then
        settings_popup.visible = false
    else
        refresh = true
    end
end

prompt.changed_callback = function (input)
    if refresh then
        filtered_entries = {}
        for i = 1, #all_entries do
            if all_entries[i].text:lower():find(input:lower()) then
                table.insert(filtered_entries, all_entries[i])
            end
        end
        
        rows:reset()
        for i = 1, math.min(#filtered_entries, max_rows[header.visible]) do
            rows:add(new_row(filtered_entries[i]))
        end
        
        index = 1
        if rows.children[index] then
            rows.children[index]:set_bg(beautiful.bg_focus)
        end
        
        refresh = false
    end
end

prompt.exe_callback = function ()
    prompt:run()
end

settings_popup:connect_signal("property::visible", function(self)
    if self.visible then
        main_menu()
        prompt:run()
        client.connect_signal("button::press", self.hide)
        awesome.connect_signal("button::press", self.hide)
    else
        rows:reset()
        awful.keygrabber.stop()
        client.disconnect_signal("button::press", self.hide)
        awesome.disconnect_signal("button::press", self.hide)
        collectgarbage()
    end
end)


return settings_popup