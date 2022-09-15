#!/bin/sh
# Low battery warning script

#off=5
low=15
high=42

charging=`acpi -b | grep "Charging"`
level=`cat /sys/class/power_supply/BAT0/charge_now`
full_level=`cat /sys/class/power_supply/BAT0/charge_full_design`
current_level=`expr "$level" \* 100 / "$full_level"`

if [ ! -n "$charging" ] && [ "$current_level" -lt "$low" ]; then
    notify-send -u critical "LOW BATTERY ($current_level%)"
#elif [ -n "$charging" ] && [ "$current_level" -ge "$high" ];then
#    notify-send -u normal "FULL BATTERY ($current_level%)"
fi
