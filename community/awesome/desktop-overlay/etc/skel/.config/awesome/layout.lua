-- joaopauloalbq
-------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local dovetail = require("awesome-dovetail")
-------------------------------------------------------------------------------------------------------------------
-- Table of layouts to cover with awful.layout.inc, order matters.
return {
    awful.layout.suit.tile,
    dovetail.layout.right,
    awful.layout.suit.tile.bottom,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    -- awful.layout.suit.magnifier,
    awful.layout.suit.floating,
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.tile.left,
    awful.layout.suit.max
}
-------------------------------------------------------------------------------------------------------------------
