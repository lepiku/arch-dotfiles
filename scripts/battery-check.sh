#!/bin/sh
# Low battery warning script

source ~/.config/script.conf
: '
$battery_low
$battery_high
$battery_notify_high
'

app_name="battery-check.sh"

charging=`acpi -b | grep "Charging"`
level=`cat /sys/class/power_supply/BAT0/charge_now`
full_level=`cat /sys/class/power_supply/BAT0/charge_full_design`
current_level=`expr "$level" \* 100 / "$full_level"`

if [ ! -n "$charging" ] && [ "$current_level" -lt "$battery_low" ]; then
    notify-send -u critical -a $app_name -i xfce4-battery-critical \
        "LOW BATTERY ($current_level%)" "Connect charger!"
elif [ $battery_notify_high = true ] \
        && [ -n "$charging" ] \
        && [ "$current_level" -ge "$battery_high" ]; then
    notify-send -u normal -a $app_name -i battery-full-charged \
        "Full Battery ($current_level%)" "Disconnect charger!"
else
    echo "Nothing to do."
fi
