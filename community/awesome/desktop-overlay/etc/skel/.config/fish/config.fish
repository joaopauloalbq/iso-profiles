set -g fish_greeting ''

if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_prompt
    set -l prompt_symbol '$ '
    fish_is_root_user; and set prompt_symbol '# '
    
    echo -s (set_color -o blue) '[' \
    (set_color -o cyan) $USER '@' (prompt_hostname) \
    (set_color -o yellow) ' ' (prompt_pwd) \
    (set_color -o blue) ']' \
    (set_color -o purple) (fish_git_prompt) \
    (set_color -o green) $prompt_symbol \
    (set_color normal)
end

alias ls='exa'
alias la='exa -la'
alias ll='exa -lh'
alias lt='exa --tree'
alias cat='bat'
alias grep='rg'
alias cal='cal -3'
alias diff='diff --color=always'
alias nano='micro'
alias fetch='neofetch'
alias term='xfce4-terminal'
alias pipes='pipes.sh'
alias intop='sudo intel_gpu_top'
alias awconf='micro ~/.config/awesome/rc.lua'
alias piconf='micro ~/.config/picom/picom.conf'
alias upsearch='sudo updatedb -U "$HOME" -e "$HOME/.config" -e "$HOME/.local" -e "$HOME/.cache"'

abbr -a pi pamac install
abbr -a pr pamac remove -o
abbr -a ps pamac search
abbr -a pu pamac update
abbr -a pc pamac checkupdates
abbr -a pd pamac info