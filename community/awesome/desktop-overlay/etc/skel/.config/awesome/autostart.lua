local awful = require("awful")


local function spawn_once(exeCmd, exeArgs, exeBefore)
	exeArgs = exeArgs or ''
	exeBefore = (exeBefore and exeBefore .. ' &&') or ''
    
    awful.spawn(string.format([[sh -c "pidof %s || %s %s %s"]], exeCmd, exeBefore, exeCmd, exeArgs), false)
end

spawn_once('picom')
-- spawn_once('nm-applet')
spawn_once('megasync','--style Fusion', 'sleep 1.1')
-- spawn_once('udiskie','-s -a')
-- spawn_once('blueman-tray')
spawn_once('/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1')
spawn_once('clipmenud')
awful.spawn.with_shell([[killall touchegg; touchegg]])
