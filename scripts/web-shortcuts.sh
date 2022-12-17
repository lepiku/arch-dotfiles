#!/bin/bash

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
