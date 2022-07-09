#!/bin/bash
# Watch change audio profile to Duplex

while IFS= read -r LOGLINE || [[ -n "$LOGLINE" ]]
do
    printf '%s\n' "$LOGLINE"
    if [[ "${LOGLINE}" == "Event 'change' on sink"* ]]
    then
        echo "setting profile"
        pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
    fi

done < <(pactl subscribe)
