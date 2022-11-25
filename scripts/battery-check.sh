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
$battery_notification_id
'

app_name="battery-check.sh"

charging=`acpi -b | grep "Charging"`
level=`cat /sys/class/power_supply/BAT0/charge_now`
full_level=`cat /sys/class/power_supply/BAT0/charge_full_design`
current_level=`expr "$level" \* 100 / "$full_level"`


if [ ! -n "$charging" ]  && [ "$current_level" -lt "$battery_low" ]; then
    echo "Low battery."
    if [ $battery_notified_low_battery = false ]; then
        echo -e "\tNotified."
        set-script-state "battery_notified_low_battery" true
        notif_id=`
            notify-send -u critical -a $app_name -i xfce4-battery-critical -t 0 -p \
                "LOW BATTERY ($current_level%)" "Connect charger\!"`
        set-script-state "battery_notification_id" $notif_id
    fi

elif [ $battery_notify_high = true ] \
        && [ -n "$charging" ] \
        && [ "$current_level" -ge "$battery_high" ]; then
    echo "Full battery."
    if [ $battery_notified_high_battery = false ]; then
        echo -e "\tNotified."
        set-script-state "battery_notified_high_battery" true
        notif_id=`
            notify-send -u normal -a $app_name -i battery-full-charged -t 0 -p \
                "Full Battery ($current_level%)" "Disconnect charger\!"`
        set-script-state "battery_notification_id" $notif_id
    fi

else
    echo "Nothing to do."
    set-script-state "battery_notified_low_battery" false
    set-script-state "battery_notified_high_battery" false
    if [ $battery_notification_id != -1 ]; then
        notify-send -u normal -a $app_name -i battery-full-charged -t 1 "." \
            -r $battery_notification_id
        set-script-state "battery_notification_id" -1
    fi
fi
