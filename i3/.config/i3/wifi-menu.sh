#!/usr/bin/env bash
# Wi-Fi menu with rofi + NetworkManager.
# Lists the visible networks (signal + lock), connects on selection, and asks
# for the password with rofi when the network is secured and not yet saved.
set -u

rofi_menu() { rofi -dmenu -i -p "Wi-Fi" -theme-str 'window { width: 560px; } listview { lines: 12; }'; }
notify() { command -v notify-send >/dev/null 2>&1 && notify-send "Wi-Fi" "$1"; }

# If the radio is off, offer to turn it on and stop here.
if [ "$(nmcli -t -f WIFI radio)" = "disabled" ]; then
    pick=$(printf '%s\n' "󰖩  Enable Wi-Fi" | rofi_menu)
    [ -n "$pick" ] && nmcli radio wifi on && notify "Wi-Fi enabled"
    exit 0
fi

# Trigger a rescan so the list is fresh (best effort, non-fatal).
nmcli device wifi rescan >/dev/null 2>&1 || true

# Signal strength -> Nerd Font glyph.
bars() {
    local s=$1
    if   [ "$s" -ge 75 ]; then echo "󰤨"
    elif [ "$s" -ge 50 ]; then echo "󰤥"
    elif [ "$s" -ge 25 ]; then echo "󰤢"
    else                       echo "󰤟"; fi
}

declare -A SSID_OF SEC_OF
menu=""
# Fields: IN-USE, SIGNAL, SECURITY, SSID (SSID last so trailing ':' in a name
# does not shift the other columns; nmcli -t escapes literal ':' as '\:').
while IFS= read -r line; do
    inuse=$(cut -d: -f1 <<<"$line")
    signal=$(cut -d: -f2 <<<"$line")
    sec=$(cut -d: -f3 <<<"$line")
    ssid=$(cut -d: -f4- <<<"$line"); ssid=${ssid//\\:/:}
    [ -z "$ssid" ] && continue                       # skip hidden networks
    [ "$inuse" = "*" ] && mark="󰸞" || mark=" "
    [ -n "$sec" ] && lock="󰍁" || lock=" "
    row="$mark $(bars "${signal:-0}")  $ssid  $lock"
    SSID_OF["$row"]="$ssid"
    SEC_OF["$row"]="$sec"
    menu+="$row"$'\n'
done < <(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list)

# Footer actions.
menu+="󰑐  Rescan"$'\n'
menu+="󰖪  Disable Wi-Fi"

choice=$(printf '%s' "$menu" | rofi_menu)
[ -z "$choice" ] && exit 0

case "$choice" in
    "󰑐  Rescan")        exec "$0" ;;
    "󰖪  Disable Wi-Fi") nmcli radio wifi off && notify "Wi-Fi disabled"; exit 0 ;;
esac

ssid=${SSID_OF["$choice"]:-}
sec=${SEC_OF["$choice"]:-}
[ -z "$ssid" ] && exit 0

# Already a saved connection? Just bring it up.
if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
    nmcli connection up id "$ssid" >/dev/null 2>&1 \
        && notify "Connected to $ssid" || notify "Could not connect to $ssid"
    exit 0
fi

# New network: ask for a password if it is secured.
if [ -n "$sec" ]; then
    pass=$(rofi -dmenu -password -p "Password for $ssid" -theme-str 'window { width: 420px; } listview { enabled: false; }')
    [ -z "$pass" ] && exit 0
    nmcli device wifi connect "$ssid" password "$pass" >/dev/null 2>&1 \
        && notify "Connected to $ssid" || notify "Could not connect to $ssid"
else
    nmcli device wifi connect "$ssid" >/dev/null 2>&1 \
        && notify "Connected to $ssid" || notify "Could not connect to $ssid"
fi
