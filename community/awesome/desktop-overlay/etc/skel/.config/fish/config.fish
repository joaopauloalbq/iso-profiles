set -U fish_greeting

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

alias ls='eza'
alias la='eza -la'
alias ll='eza -lh'
alias lt='eza --tree'
alias grep='rg'
alias cat='bat'
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
abbr -a gad git add
abbr -a gbr git branch
abbr -a gco git commit
abbr -a gcl git clone
abbr -a gck git checkout
abbr -a gcp git cherry-pick 
abbr -a gdi git diff
abbr -a gfe git fetch
abbr -a gin git init
abbr -a glo git log --graph --abbrev-commit --pretty=oneline
abbr -a gme git merge
abbr -a grb git rebase
abbr -a grt git restore
abbr -a grm git remote
abbr -a gst git status
abbr -a gsw git switch
abbr -a gpu git pull
abbr -a gpx git push
abbr -a gt git tag

abbr -a ra ranger
abbr -a laz lazygit
