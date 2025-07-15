export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
# export XDG_CURRENT_DESKTOP="Unity"
export FONTCONFIG_PATH=/etc/fonts
export FONTCONFIG_FILE=fonts.conf
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_SCALE_FACTOR=1
export GTK_USE_PORTAL=0
export GTK_THEME="Suit-Pink-Dark-Compact-Nord"
export TERMINAL="xterm"
export VISUAL="micro"
export EDITOR="micro"
export MICRO_TRUECOLOR=1
export FZF_DEFAULT_OPTS="--color=fg:-1,bg:-1,hl:green --color=fg+:bright-white,bg+:bright-black,gutter:black,hl+:bright-green --color=info:yellow,prompt:blue,pointer:bright-green --color=marker:cyan,spinner:bright-magenta,header:blue --prompt ' ∷ ' --pointer '󰐊'  --marker '●'"
export BAT_THEME="base16"
export RANGER_LOAD_DEFAULT_RC=FALSE
# clipmenu rofi support
export CM_LAUNCHER=rofi
export CM_DIR=~/.local/share/
export CM_SELECTIONS=clipboard
export CM_HISTLENGTH=9
export CM_MAX_CLIPS=1000
export CM_IGNORE_WINDOW="KeePassXC"
# udiskie rofi support
export UDISKIE_DMENU_LAUNCHER="rofi"
export DO_NOT_UNSET_QT_QPA_PLATFORMTHEME=1 
export DO_NOT_SET_DESKTOP_SETTINGS_UNAWARE=1
xdg-user-dirs-update
