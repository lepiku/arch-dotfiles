#!/bin/sh

image_name="$HOME/Pictures/Screenshots/$(date +%F_%H-%M-%S-%N | cut -c -23).png"

_maim() {
    maim $* $image_name
    xclip -selection clipboard -t image/png $image_name
}

case $1 in
    screen)
        _maim
        ;;

    select)
        _maim -su
        ;;
esac
