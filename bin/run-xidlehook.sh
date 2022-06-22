#!/bin/sh

xidlehook \
  `# Don't lock when there's a fullscreen application` \
  --not-when-fullscreen \
  `# Don't lock when there's audio playing` \
  `#--not-when-audio` \
  `# sleep after 10 minutes` \
  --timer 600 \
    'xset dpms force off' \
    'xset dpms force on' \
  --timer 10 \
    'systemctl suspend' \
    ''
