if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

xrdb -merge .Xresources

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

fcitx 2> ${HOME}/logs/fcitx.stderr.log &
compton -b --config ~/.compton.conf &

#exec xautolock -time 30 -locker "~/dotfiles/lock.sh" &
exec i3
