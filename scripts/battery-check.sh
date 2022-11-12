#!/bin/sh
# Low battery warning script

source ~/.config/script.conf
: '
$battery_low
$battery_high
$battery_notify_high
'

charging=`acpi -b | grep "Charging"`
level=`cat /sys/class/power_supply/BAT0/charge_now`
full_level=`cat /sys/class/power_supply/BAT0/charge_full_design`
current_level=`expr "$level" \* 100 / "$full_level"`

if [ ! -n "$charging" ] && [ "$current_level" -lt "$battery_low" ]; then
    notify-send -u critical "LOW BATTERY ($current_level%)"
elif [ $battery_notify_high = true ] \
        && [ -n "$charging" ] \
        && [ "$current_level" -ge "$battery_high" ]; then
    notify-send -u normal "FULL BATTERY ($current_level%)"
fi
