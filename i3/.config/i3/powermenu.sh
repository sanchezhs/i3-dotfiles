#!/usr/bin/env bash
# Power menu with rofi, themed by wallust (uses ~/.config/rofi/config.rasi,
# same as the Wi-Fi and app menus). Icons are Nerd Font glyphs; the chosen
# action is matched on the full label.

shutdown_e="󰐥  Shutdown"
reboot_e="󰜉  Reboot"
lock_e="󰌾  Lock"
logout_e="󰍃  Logout"
suspend_e="󰤄  Suspend"
hibernate_e="󰜗  Hibernate"

options="$shutdown_e
$reboot_e
$lock_e
$logout_e
$suspend_e
$hibernate_e"

choice=$(printf '%s\n' "$options" | rofi -dmenu -i -p "Power" \
    -theme-str 'window { width: 320px; } listview { lines: 6; } element-text { vertical-align: 0.5; }')

case "$choice" in
    "$shutdown_e")  systemctl poweroff ;;
    "$reboot_e")    systemctl reboot ;;
    "$lock_e")      i3lock -c 000000 ;;
    "$logout_e")    i3-msg exit ;;
    "$suspend_e")   systemctl suspend ;;
    "$hibernate_e") systemctl hibernate ;;
    *)              exit 0 ;;   # dismissed / no valid choice
esac
