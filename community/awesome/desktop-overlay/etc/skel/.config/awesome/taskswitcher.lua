--[[-- Task switcher widget that replaces Mod4 + j/k for switching windows.

@widget ndgnuh.taskswitcher

- All windows will be shown.
- Use <Mod4 + j/k> to move up/down.
- Windows won't be focused until <Mod4> is released.

TODO:

- allow custom keybindings, maybe with refracting
- documentation on the methods
- allow theming + custom client item templates

@todo: all of the above

@usage
require("ndgnuh.taskswitcher").setup()
]]
local capi = { root = root, awesome = awesome, screen = screen, client = client }
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local gtable = require("gears.table")
local gears = require("gears")
local cthumbnail = require("clientthumbnail")

--- Task switcher prototype
local taskswitcher = {
    thumbnails = setmetatable({}, { __mode = "k" }), -- the client preview
    current = nil,
    enabled = true,
}

--- A function to get all the clients.
-- The clients are across the screen and presented in consistent order.
function taskswitcher:get_clients()
    -- Get all clients from all the screen
    -- Do not use the stacked order since it changes every time
    local clients = {}
    for s in capi.screen do
        clients = gtable.join(clients, s:get_all_clients(false))
    end
    return clients
end

--- Focus client across tags and screens
-- 1. focus to the client's screen
-- 2. view the client's first tag
-- 3. focus and raise the client
-- @tparam client c : awesome's client
function taskswitcher:focus(c)
    -- check wanted/focused client
    if not c then return end
    if c == client.focus then return end

    -- focus everything
    awful.screen.focus(c.screen)
    awful.tag.viewonly(c.first_tag)

    -- have to do this because sometime
    -- "raise" does not work
    local callback
    callback = function(fc)
        if fc then fc:raise() end
        client.disconnect_signal("focus", callback)
    end
    client.connect_signal("focus", callback)
    client.focus = c or client.focus
    c:emit_signal("request::activate", "key.unminimize", { raise = true })
end

function taskswitcher:get_idx()
    if self.current then return self.current end
    local clients = self:get_clients()
    local c = capi.client.focus
    local current = nil
    for i, c_i in ipairs(clients) do
        if c_i == c then current = i end
    end
    self.current = current
end

function taskswitcher:next()
    local first = not self.popup.visible
    self:show()
    local clients = self:get_clients()
    if #clients == 0 then return end
    if self.current < #clients then
        self.current = self.current + 1
    else
        self.current = 1
    end

    -- redraw if first time, else rehighlight
    if first then
        self:redraw(clients, self.current)
        self:rehighlight(self.current)
    else
        self:rehighlight(self.current)
    end
end

function taskswitcher:prev()
    local first = not self.popup.visible
    self:show()
    local clients = self:get_clients()
    if #clients == 0 then return end
    if self.current > 1 then
        self.current = self.current - 1
    else
        self.current = #clients
    end

    -- redraw if first time, else rehighlight
    if first then
        self:redraw(clients, self.current)
    else
        self:rehighlight(self.current)
    end
end

--- Show the visible widget
function taskswitcher:show()
    -- Mark the current client index
    -- when first shown
    if not self.current then
        local clients = self:get_clients()
        local c = capi.client.focus
        local current = 1
        for i, c_i in ipairs(clients) do
            if c_i == c then current = i end
        end
        self.current = current
    end

    -- show the popup
    self.popup.visible = true
end

function taskswitcher:hide()
    -- focus selected client
    local clients = self:get_clients()
    local idx = self.current
    local c = clients[idx]
    self:focus(c)

    -- mark previously focused idx
    -- and clean up
    self.previous = self.current
    self.current = nil
    self.popup.visible = false
end

function taskswitcher:redraw(clients, idx)
    --- The layout
    -- +----------------+------------------------+
    -- + client 1       +                        +
    -- + client 2       +        preview         +
    -- + <client 3>     +          of            +
    -- + client 3       +        selected        +
    -- + client 4       +         client         +
    -- + client 5       +                        +
    -- +----------------+------------------------+
    local popup = self.popup
    popup.widget = wibox.widget {
        widget = wibox.layout.align.horizontal,
        {
            id = "client_list",
            widget = wibox.layout.flex.vertical,
        },
        {
            id = "client_preview_container",
            widget = wibox.container.place,
        }
    }

    -- setup
    local widget = popup.widget
    local client_list = widget:get_children_by_id("client_list")[1]
    local client_preview_container = widget:get_children_by_id("client_preview_container")[1]
    widget.preview_list = {}

    for i, c in ipairs(clients) do
        -- pick the colors
        local focus_color = beautiful.primary or beautiful.bg_focus
        local bg = i == idx and focus_color or beautiful.bg_normal
        local fg = i == idx and (beautiful.fg_focus or "#FFF") or beautiful.fg_normal

        -- layout the clients
        -- local item = wibox.widget {
        --     widget = wibox.container.background,
        --     bg = bg,
        --     {
        --         widget = wibox.container.margin,
        --         margins = beautiful.wibar_height / 2,
        --         {
        --             {
        --                 widget = wibox.container.constraint,
        --                 forced_height = image_height,
        --                 forced_width = image_height * 16 / 10,
        --                 width = beautiful.wibar_height,
        --                 height = beautiful.wibar_height,
        --                 {
        --                     widget = cthumbnail,
        --                     client = c,
        --                 },
        --             },
        --             {
        --                 widget = wibox.container.place,
        --                 wibox.widget.textbox(TextColor(c.name or c.class or "Untitled", fg)),
        --             },
        --             spacing = beautiful.wibar_height / 4,
        --             widget = wibox.layout.fixed.vertical,
        --         }
        --     },
        -- }
        local item = wibox.widget {
            id = "background_role",
            widget = wibox.container.background,
            {
                widget = wibox.container.constraint,
                width = 600,
                {
                    widget = wibox.widget.textbox,
                    markup = "<b>" .. tostring(i) .. ". " .. tostring(c.name or c.class or "Untitled") .. "</b>",
                }
            }
        }

        -- preview widget
        local preview = wibox.widget {
            forced_width = 1024,
            forced_height = 640,
            widget = cthumbnail,
            client = c,
        }
        table.insert(widget.preview_list, preview)
        if client.focus == c then
            client_preview_container:set_children({ preview })
        end

        -- add widget
        client_list:add(item)
    end
end

--- Rehightlight the background widget without redrawing everything
function taskswitcher:rehighlight(idx)
    local widget = self.popup.widget
    local client_list = widget:get_children_by_id("client_list")[1]
    local client_preview_container = widget:get_children_by_id("client_preview_container")[1]

    for i, _ in ipairs(client_list.children) do
        local selected = i == idx
        local focus_color = beautiful.primary or beautiful.bg_focus
        local client_name = client_list.children[i]
        if selected then
            client_name.bg = focus_color
            client_preview_container:set_children({ widget.preview_list[i] })
        else
            client_name.bg = beautiful.bg_normal
        end
    end
end

--- Toggle task switcher
function taskswitcher:toggle()
    self.enabled = not self.enabled
end

--- Make task switcher widget
function taskswitcher:setup()
    self.popup = awful.popup {
        visible = false,
        ontop = true,
        border_color = beautiful.primary or beautiful.border_focused,
        border_width = beautiful.border_width or 2,
        shape = gears.shape.rounded_rect,
        placement = awful.placement.centered,
        widget = wibox.widget {
            widget = wibox.layout.flex.vertical,
            homogeneous = true,
        }
    }

    -- Grab key to popup
    self.keygrabber = awful.keygrabber {
        keybindings = {
            { { "Mod4" }, "j", function() if self.enabled then self:next() else awful.client.focus.byidx(1) end end },
            { { "Mod4" }, "k", function() if self.enabled then self:prev() else awful.client.focus.byidx(-1) end end },
        },
        export_keybindings = true,
        stop_callback = function()
            self:hide()
        end,
        stop_key = 'Mod4',
        stop_event = 'release',
    }
end

taskswitcher:setup()

return taskswitcher
