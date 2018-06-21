#!/bin/sh
# Executed by startx
# By calling this with arguments we can start different sessions
# eg. startx ~/.xinitrc i3  or  startx ~/.xinitrc bspwm
# simply using startx, openbox is set as the default

session=${1:-bspwm}
export WM="$session"
#export PATH="${PATH}:/home/canoi/.executor"
export PATH="${PATH}:/home/canoi/.custom"

if [ -f /etc/X11/xinit/.Xmodmap ]; then
    xmodmap /etc/X11/xinit/.Xmodmap
fi

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*.sh; do
        [ -x "$f" ] && . "$f"
    done
fi

if [ -f ~/.Xresources ]; then
    xrdb -load ~/.Xresources
fi

if [ -f ~/.Xmodmap ]; then
    xmodmap ~/.Xmodmap
fi

if [ -f ~/.xprofile ]; then
    . ~/.xprofile
fi

gnome-keyring-daemon --start --components=pkcs11 &
lxpolkit &
kbdrate -d 400 -r 50
xset r rate 400 50
xset s 3600 3600

xsetroot -cursor_name left_ptr

# Add this to your .xinitrc or whatever file starts programs on startup.
# -R restores the last colorscheme that was in use.
#wal -R -g

#export PATH="${PATH}:$HOME/.notify"

# start the session
case $session in
    i3|i3wm)    exec i3 ;;
    bsp|bspwm)  exec bspwm ;;
    awesome)    exec awesome ;;
    xfce|xfce4) exec startxfce4 ;;
    openbox|openbox-session) exec openbox-session ;;
    *) exec "$1"
esac
