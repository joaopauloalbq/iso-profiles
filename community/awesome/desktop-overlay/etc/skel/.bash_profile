if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --login)
    export SSH_AUTH_SOCK
fi
