# export XDG_CONFIG_DIRS=/etc/xdg
# export XDG_CURRENT_DESKTOP=X-Generic
export XDG_CONFIG_HOME="$HOME/.config"
export FONTCONFIG_PATH=/etc/fonts
export FONTCONFIG_FILE=fonts.conf
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_SCALE_FACTOR=1
export GTK_USE_PORTAL=1
export TERMINAL="xfce4-terminal"
export VISUAL="micro"
export EDITOR="micro"
export MICRO_TRUECOLOR=1
# clipmenu rofi support
export CM_LAUNCHER=rofi
export CM_DIR=~/.local/share/
export CM_SELECTIONS=clipboard
export CM_HISTLENGTH='9'
# udiskie rofi support
export UDISKIE_DMENU_LAUNCHER='rofi'

xdg-user-dirs-update
