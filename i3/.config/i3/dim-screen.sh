#!/usr/bin/env bash
# xss-lock notifier: fades the laptop backlight down during the warning period
# before locking (see `xset s` in the i3 config). Any input cancels it and
# xss-lock kills this script, which restores the previous brightness.
# Based on /usr/share/doc/xss-lock/dim-screen.sh (uses acpilight's xbacklight).

min_brightness=5   # percent
prev=$(xbacklight -get)

trap 'exit 0' TERM INT
trap 'xbacklight -steps 1 -set "$prev"; kill %% 2>/dev/null' EXIT

xbacklight -time 1000 -steps 20 -set "$min_brightness"
sleep infinity &
wait
