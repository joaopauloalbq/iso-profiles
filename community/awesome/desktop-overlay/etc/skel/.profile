export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
# export XDG_CURRENT_DESKTOP="Unity"
export FONTCONFIG_PATH=/etc/fonts
export FONTCONFIG_FILE=fonts.conf
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_SCALE_FACTOR=1
export GTK_USE_PORTAL=0
export TERMINAL="xterm"
export VISUAL="micro"
export EDITOR="micro"
export MICRO_TRUECOLOR=1
export FZF_DEFAULT_OPTS="--color=fg:-1,bg:-1,hl:green --color=fg+:bright-white,bg+:bright-black,gutter:black,hl+:bright-green --color=info:yellow,prompt:blue,pointer:bright-green --color=marker:cyan,spinner:bright-magenta,header:blue --prompt ' ∷ ' --pointer '󰐊'  --marker '●'"
# clipmenu rofi support
export CM_LAUNCHER=rofi
export CM_DIR=~/.local/share/
export CM_SELECTIONS=clipboard
export CM_HISTLENGTH="9"
# udiskie rofi support
export UDISKIE_DMENU_LAUNCHER="rofi"

xdg-user-dirs-update
