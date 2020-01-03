#!/bin/sh
# Low battery warning script

low=25
high=80

export DISPLAY=:0
charging=`acpi -b | grep "Charging"`
level=`cat /sys/class/power_supply/BAT0/charge_now`
full_level=`cat /sys/class/power_supply/BAT0/charge_full_design`
current_level=`expr "$level" \* 100 / "$full_level"`

echo "Battery: $current_level%"
if [ ! -n "$charging" ] && [ "$current_level" -lt "$low" ]; then
    i3-nagbar -f "pango:SourceCodePro SemiBold 10" -m "LOW BATTERY: Battery < $low%"
elif [ -n "$charging" ] && [ "$current_level" -ge "$high" ];then
    i3-nagbar -f "pango:SourceCodePro SemiBold 10" -m "FULL BATTERY: Battery > $high%" -t "warning"
fi
