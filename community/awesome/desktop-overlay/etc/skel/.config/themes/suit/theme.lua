---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gears = require("gears")
local lain  = require("lain")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = {}

theme.font          = "Noto Sans 11"

theme.bg_normal     = "#363636" --#353535
theme.bg_focus      = "#5B5B5B"
theme.bg_urgent     = "#F06C6C"
theme.bg_minimize   = "#212121" -- #272727
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#DEDEDE" --#aaaaaa"
theme.fg_focus      = "#FAFAFA"
theme.fg_urgent     = "#EDEDED"
theme.fg_minimize   = "#D4D4D4"

theme.useless_gap   = 3
-- theme.gap_single_client = false
theme.border_width  = 2
theme.border_normal = "#666666"
theme.border_focus  = "#41C6C8" -- #64A7A7 #41C6C8 #222222
theme.border_marked = "#64A7A7"

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
-- theme.notification_height = dpi(60)
theme.notification_bg = "#464647" -- theme.bg_focus
theme.notification_fg = theme.fg_focus
theme.notification_border_width = theme.border_width
theme.notification_border_color = theme.border_focus
theme.notification_icon_size = dpi(48)
theme.notification_width = dpi(346) -- 346 FOR OSD NOTIFICATIONS
theme.notification_margin = dpi(8)  --6

-- There are other variable sets
-- overriding the suit one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

theme.titlebar_bg_normal = theme.bg_normal
theme.titlebar_bg_focus = theme.bg_normal

theme.hotkeys_label_fg = theme.fg_normal
theme.hotkeys_modifiers_fg = theme.fg_focus
theme.hotkeys_border_color = theme.border_focus
theme.hotkeys_description_font = theme.font
theme.hotkeys_font = theme.font
-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "~/.config/awesome/themes/suit/submenu.png"
theme.menu_height = dpi(28)
theme.menu_width  = dpi(240)
theme.menu_bg_normal  = "#424242"
theme.menu_bg_focus  = "#616161"
theme.menu_border_color  = "#2C2C2C"
theme.menu_border_width  = dpi(1)

theme.snap_border_width = dpi(3)
theme.snap_shape = gears.shape.rectangle
-- theme.snap_bg = "#00000000"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = "~/.config/awesome/themes/suit/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = "~/.config/awesome/themes/suit/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = "~/.config/awesome/themes/suit/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = "~/.config/awesome/themes/suit/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = "~/.config/awesome/themes/suit/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = "~/.config/awesome/themes/suit/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "~/.config/awesome/themes/suit/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = "~/.config/awesome/themes/suit/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "~/.config/awesome/themes/suit/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = "~/.config/awesome/themes/suit/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "~/.config/awesome/themes/suit/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = "~/.config/awesome/themes/suit/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "~/.config/awesome/themes/suit/titlebar/sepa.png"
theme.titlebar_floating_button_focus_inactive  = "~/.config/awesome/themes/suit/titlebar/sepa.png"
theme.titlebar_floating_button_normal_active = "~/.config/awesome/themes/suit/titlebar/sepa.png"
theme.titlebar_floating_button_focus_active  = "~/.config/awesome/themes/suit/titlebar/sepa.png"

theme.titlebar_maximized_button_normal_inactive = "~/.config/awesome/themes/suit/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = "~/.config/awesome/themes/suit/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "~/.config/awesome/themes/suit/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = "~/.config/awesome/themes/suit/titlebar/maximized_focus_active.png"

theme.wallpaper = "~/.wallpaper"

-- You can use your own layout icons like this:
theme.layout_fairh = "~/.config/awesome/themes/suit/layouts/fairhw.png"
theme.layout_fairv = "~/.config/awesome/themes/suit/layouts/fairvw.png"
theme.layout_floating  = "~/.config/awesome/themes/suit/layouts/floatingw.png"
theme.layout_magnifier = "~/.config/awesome/themes/suit/layouts/magnifierw.png"
theme.layout_max = "~/.config/awesome/themes/suit/layouts/maxw.png"
theme.layout_fullscreen = "~/.config/awesome/themes/suit/layouts/fullscreen.png"
theme.layout_tilebottom = "~/.config/awesome/themes/suit/layouts/tilebottomw.png"
theme.layout_tileleft   = "~/.config/awesome/themes/suit/layouts/tileleftw.png"
theme.layout_tile = "~/.config/awesome/themes/suit/layouts/tilew.png"
theme.layout_tiletop = "~/.config/awesome/themes/suit/layouts/tiletopw.png"
theme.layout_spiral  = "~/.config/awesome/themes/suit/layouts/spiralw.png"
theme.layout_dwindle = "~/.config/awesome/themes/suit/layouts/dwindlew.png"
theme.layout_cornernw = "~/.config/awesome/themes/suit/layouts/cornernww.png"
theme.layout_cornerne = "~/.config/awesome/themes/suit/layouts/cornernew.png"
theme.layout_cornersw = "~/.config/awesome/themes/suit/layouts/cornersww.png"
theme.layout_cornerse = "~/.config/awesome/themes/suit/layouts/cornersew.png"
theme.layout_centerwork = "~/.config/awesome/themes/suit/layouts/centerwork.svg"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_normal, theme.fg_focus
)

-- Textclock
-- os.setlocale(os.getenv("LANG")) -- to localize the clock
-- local mytextclock = wibox.widget.textclock("  %a %d, %H:%M  ")

-- System tray
theme.systray_icon_spacing = 6

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "Papirus-Dark"

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

-- Rofi
file = io.open(".config/rofi/colors.rasi", "r")
content = file:read("*a")
file:close()

content = content:gsub("background%-color: (%g+);", ("background-color: " .. theme.bg_normal .. ";"), 1)
content = content:gsub("darker%-background%-color: (%g+);", ("darker-background-color: " .. "#303030" .. ";"), 1)
content = content:gsub("border%-color: (%g+);", ("border-color: " .. theme.bg_minimize .. ";"), 1)
content = content:gsub("text%-color: (%g+);", ("text-color: " .. theme.fg_normal .. ";"), 1)
content = content:gsub("brighter%-text%-color: (%g+);", ("brighter-text-color: " .. theme.fg_focus .. ";"), 1)
content = content:gsub("highlight%-color: (%g+);", ("highlight-color: " .. theme.border_focus .. ";"), 1)
content = content:gsub("darker%-highlight%-color: (%g+);", ("darker-highlight-color: " .. "#2B9294" .. ";"), 1)
content = content:gsub("border: (%g+);", ("border: " .. (theme.border_width + 2) .. ";"), 1)

file = io.open(".config/rofi/colors.rasi", "w+")
file:write(content)
file:close()

return theme
