#!/bin/bash
#
# used with rofi. Example:
#
# bash scripts/web-shortcuts.sh \
#     `bash scripts/web-shortcuts.sh | rofi -dmenu -i -p "Web Shortcuts"`

filename="$HOME/.config/web-shortcuts-mapping.txt"
mapfile -t myArray < "$filename"

for i in "${myArray[@]}"; do
    key=`echo "$i" | cut -d";" -f1`
    value=`echo "$i" | cut -d";" -f2`

    if [[ -n "$@" && "$@" == "$key" ]]; then
        eval $value
    elif [ -z "$@" ]; then
        echo "$key"
    fi
done
