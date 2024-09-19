#!/bin/sh

 cp "$1" "$2"
 while inotifywait -e close_write "$1"; do
     cp "$1" "$2"
 done

