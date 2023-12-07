function ranger --description 'Terminal file manager'
    if test -n "$RANGER_LEVEL"
        exit
    else
        command ranger $argv
    end
end
