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

theme.font          = "Noto Sans Medium 11"

theme.bg_normal     = "#2d323a"
theme.bg_focus      = "#4c5158"
theme.bg_urgent     = "#F06C6C"
theme.bg_minimize   = "#1e222a"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#DEDEDE"
theme.fg_focus      = "#FAFAFA"
theme.fg_urgent     = "#EDEDED"
theme.fg_minimize   = "#D4D4D4"

theme.useless_gap   = 3
-- theme.gap_single_client = false
theme.border_width  = 2
theme.corner_radius = 11
theme.border_normal = "#474b53"
theme.border_focus  = "#dc98b1"
theme.border_marked = "#64A7A7"

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
-- theme.notification_height = dpi(60)
theme.notification_bg = "#333942"
theme.notification_fg = theme.fg_focus
theme.notification_border_width = theme.border_width
theme.notification_border_color = theme.border_focus
theme.notification_icon_size = dpi(48)
theme.notification_width = dpi(352)
theme.notification_margin = dpi(6)

-- There are other variable sets
-- overriding the nord-pink one when
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

theme.titlebar_bg_normal = "#1e222a" 
theme.titlebar_bg_focus = "#1e222a"

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
theme.menu_submenu_icon = "~/.config/awesome/themes/nord-pink/submenu.png"
theme.menu_height = dpi(28)
theme.menu_width  = dpi(240)
theme.menu_bg_normal  = "#323946"
theme.menu_bg_focus  = "#424955"
theme.menu_border_color  = "#3d424a"
theme.menu_border_width  = dpi(1)

theme.snap_border_width = dpi(4)
theme.snap_shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,12) end
-- theme.snap_bg = "#00000000"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = "~/.config/awesome/themes/nord-pink/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = "~/.config/awesome/themes/nord-pink/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = "~/.config/awesome/themes/nord-pink/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = "~/.config/awesome/themes/nord-pink/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = "~/.config/awesome/themes/nord-pink/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = "~/.config/awesome/themes/nord-pink/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "~/.config/awesome/themes/nord-pink/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = "~/.config/awesome/themes/nord-pink/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "~/.config/awesome/themes/nord-pink/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = "~/.config/awesome/themes/nord-pink/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "~/.config/awesome/themes/nord-pink/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = "~/.config/awesome/themes/nord-pink/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "~/.config/awesome/themes/nord-pink/titlebar/sepa.png"
theme.titlebar_floating_button_focus_inactive  = "~/.config/awesome/themes/nord-pink/titlebar/sepa.png"
theme.titlebar_floating_button_normal_active = "~/.config/awesome/themes/nord-pink/titlebar/sepa.png"
theme.titlebar_floating_button_focus_active  = "~/.config/awesome/themes/nord-pink/titlebar/sepa.png"

theme.titlebar_maximized_button_normal_inactive = "~/.config/awesome/themes/nord-pink/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = "~/.config/awesome/themes/nord-pink/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "~/.config/awesome/themes/nord-pink/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = "~/.config/awesome/themes/nord-pink/titlebar/maximized_focus_active.png"

theme.wallpaper = "~/.wallpaper"

-- You can use your own layout icons like this:
theme.layout_fairh = "~/.config/awesome/themes/nord-pink/layouts/fairhw.png"
theme.layout_fairv = "~/.config/awesome/themes/nord-pink/layouts/fairvw.png"
theme.layout_floating  = "~/.config/awesome/themes/nord-pink/layouts/floatingw.png"
theme.layout_magnifier = "~/.config/awesome/themes/nord-pink/layouts/magnifierw.png"
theme.layout_max = "~/.config/awesome/themes/nord-pink/layouts/maxw.png"
theme.layout_fullscreen = "~/.config/awesome/themes/nord-pink/layouts/fullscreen.png"
theme.layout_tilebottom = "~/.config/awesome/themes/nord-pink/layouts/tilebottomw.png"
theme.layout_tileleft   = "~/.config/awesome/themes/nord-pink/layouts/tileleftw.png"
theme.layout_tile = "~/.config/awesome/themes/nord-pink/layouts/tilew.png"
theme.layout_tiletop = "~/.config/awesome/themes/nord-pink/layouts/tiletopw.png"
theme.layout_spiral  = "~/.config/awesome/themes/nord-pink/layouts/spiralw.png"
theme.layout_dwindle = "~/.config/awesome/themes/nord-pink/layouts/dwindlew.png"
theme.layout_cornernw = "~/.config/awesome/themes/nord-pink/layouts/cornernww.png"
theme.layout_cornerne = "~/.config/awesome/themes/nord-pink/layouts/cornernew.png"
theme.layout_cornersw = "~/.config/awesome/themes/nord-pink/layouts/cornersww.png"
theme.layout_cornerse = "~/.config/awesome/themes/nord-pink/layouts/cornersew.png"
theme.layout_centerwork = "~/.config/awesome/themes/nord-pink/layouts/centerwork.svg"

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
file = io.open(".config/rofi/base.rasi", "r")
content = file:read("*a")
file:close()

content = content:gsub("background%-color: (%g+);", ("background-color: " .. theme.bg_normal .. ";"), 1)
content = content:gsub("brighter%-background%-color: (%g+);", ("brighter-background-color: " .. theme.bg_focus .. ";"), 1)
content = content:gsub("darker%-background%-color: (%g+);", ("darker-background-color: " .. "#2A2E36" .. ";"), 1)
content = content:gsub("border%-color: (%g+);", ("border-color: " .. "#232830" .. ";"), 1)
content = content:gsub("text%-color: (%g+);", ("text-color: " .. theme.fg_normal .. ";"), 1)
content = content:gsub("brighter%-text%-color: (%g+);", ("brighter-text-color: " .. theme.fg_focus .. ";"), 1)
content = content:gsub("highlight%-color: (%g+);", ("highlight-color: " .. theme.border_focus .. ";"), 1)
content = content:gsub("darker%-highlight%-color: (%g+);", ("darker-highlight-color: " .. "#c88aa1" .. ";"), 1)
content = content:gsub("border: (%g+);", ("border: " .. (theme.border_width + 2) .. "px;"), 1)
content = content:gsub("corner-radius: (%g+);", ("corner-radius: " .. (theme.corner_radius - theme.border_width) .. ";"), 1)

file = io.open(".config/rofi/base.rasi", "w+")
file:write(content)
file:close()

return theme
