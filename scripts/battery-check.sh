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
$battery_prev_plugged_in
$battery_notification_id
'

app_name="battery-check.sh"

plugged_in=`acpi -a | grep "^Adapter.*: on-line$"`
level=`cat /sys/class/power_supply/BAT0/charge_now`
full_level=`cat /sys/class/power_supply/BAT0/charge_full_design`
current_level=`expr "$level" \* 100 / "$full_level"`

if [ "$battery_notification_id" != -1 ]; then
    battery_is_notified=true
else
    battery_is_notified=false
fi

if [ ! -n "$plugged_in" ] && [ "$current_level" -le "$battery_low" ]; then
    echo "Low battery."
    if [ $battery_is_notified = false ]; then
        echo -e "\tNotifying."
        notif_id=`
            notify-send -u critical -a $app_name -i xfce4-battery-critical -t 0 -p \
                "LOW BATTERY ($current_level%)" "Connect charger\!"`
        set-script-state "battery_notification_id" $notif_id
    fi

elif [ "$battery_notify_high" = true ] \
        && [ -n "$plugged_in" ] \
        && [ "$current_level" -ge "$battery_high" ]; then
    echo "Full battery."
    if [ $battery_is_notified = false ]; then
        echo -e "\tNotifying."
        notif_id=`
            notify-send -u normal -a $app_name -i battery-full-charged -t 0 -p \
                "Full Battery ($current_level%)" "Disconnect charger\!"`
        set-script-state "battery_notification_id" $notif_id
    fi

else
    echo "Nothing to do."
    if [ "$battery_is_notified" = true ]; then
        notify-send -a $app_name -t 1 " " -r $battery_notification_id
        set-script-state "battery_notification_id" -1
    fi
fi

# notify if adapter is plugged in or unplugged
if [ "$battery_prev_plugged_in" = false ] && [ -n "$plugged_in" ]; then
    notify-send -u normal -a $app_name -i battery_plugged -p \
        "Power Plugged In"
elif [ "$battery_prev_plugged_in" = true ] && [ ! -n "$plugged_in" ]; then
    notify-send -u low -a $app_name -i battery_plugged -p \
        "Power Unplugged"
fi

if [ -n "$plugged_in" ]; then
    set-script-state "battery_prev_plugged_in" true
else
    set-script-state "battery_prev_plugged_in" false
fi
