#!/bin/sh

xidlehook \
  `# Don't lock when there's a fullscreen application` \
  --not-when-fullscreen \
  `# Don't lock when there's audio playing` \
  #--not-when-audio \
  `# sleep after 15 minutes` \
  --timer 900 \
    'systemctl suspend' \
    ''
