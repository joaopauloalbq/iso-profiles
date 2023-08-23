function fzf --wraps fzf --description 'Command-line fuzzy finder'
    command fzf --color=fg:-1,bg:-1,hl:green --color=fg+:bright-white,bg+:bright-black,gutter:black,hl+:bright-green --color=info:yellow,prompt:blue,pointer:bright-green --color=marker:cyan,spinner:bright-magenta,header:blue --prompt ' ∷ ' --pointer '▶'  --marker '▶' $argv
end
