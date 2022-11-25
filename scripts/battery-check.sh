#!/bin/sh
# Low battery warning script

source ~/.config/script.conf
: '
$battery_low
$battery_high
$battery_notify_high
'
source ~/.config/script-state.sh
: '
$battery_notified_low_battery
$battery_notified_high_battery
'

app_name="battery-check.sh"

charging=`acpi -b | grep "Charging"`
level=`cat /sys/class/power_supply/BAT0/charge_now`
full_level=`cat /sys/class/power_supply/BAT0/charge_full_design`
current_level=`expr "$level" \* 100 / "$full_level"`

if [ ! -n "$charging" ]  && [ "$current_level" -lt "$battery_low" ]; then
    echo "Low battery."
    if [ $battery_notified_low_battery = false ]; then
        echo "Notified."
        set-script-state "battery_notified_low_battery" true
        notify-send -u critical -a $app_name -i xfce4-battery-critical -t 0 \
            "LOW BATTERY ($current_level%)" "Connect charger\!"
    fi

elif [ $battery_notify_high = true ] \
        && [ -n "$charging" ] \
        && [ "$current_level" -ge "$battery_high" ]; then
    echo "Full battery."
    if [ $battery_notified_high_battery = false ]; then
        echo "Notified."
        set-script-state "battery_notified_high_battery" true
        notify-send -u normal -a $app_name -i battery-full-charged -t 0 \
            "Full Battery ($current_level%)" "Disconnect charger\!"
    fi

else
    echo "Nothing to do."
    set-script-state "battery_notified_low_battery" false
    set-script-state "battery_notified_high_battery" false
fi
