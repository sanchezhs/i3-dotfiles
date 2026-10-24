#!/usr/bin/env bash
# Launches polybar detecting monitors dynamically.
# Output names (eDP-1/eDP-2, HDMI-1-0...) can change between boots on NVIDIA
# hybrid graphics, so they are NOT hardcoded: they are resolved by role ->
# internal = eDP*, external = HDMI*/DP*.

# Lock: if this script is invoked concurrently (i3 startup + autorandr
# postswitch), the instances serialize instead of killing each other.
exec 9>"/tmp/polybar_launch.${USER}.lock"
flock 9

killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done

# Internal panel: first connected eDP
INTERNAL=$(xrandr --query | awk '/^eDP.* connected/ {print $1; exit}')

# External monitor: first connected AND active HDMI/DP (with a resolution set)
EXTERNAL=$(xrandr --query | awk '/^(HDMI|DP).* connected [0-9]+x[0-9]+\+/ {print $1; exit}')

# polybar is launched detached (setsid) with the lock fd CLOSED (9>&-), so the
# child does not inherit the lock and hold it for its whole lifetime.
#
# The "main" bar carries the systray; "secondary" does not. The tray can live
# on only one bar, so we always place "main" on a monitor that is present:
# the external one when docked, otherwise the laptop panel (so nm-applet and
# other tray icons are visible even without an external monitor).
if [ -n "$EXTERNAL" ]; then
    MONITOR=$EXTERNAL setsid polybar main >/dev/null 2>&1 9>&- &
    [ -n "$INTERNAL" ] && MONITOR=$INTERNAL setsid polybar secondary >/dev/null 2>&1 9>&- &
elif [ -n "$INTERNAL" ]; then
    MONITOR=$INTERNAL setsid polybar main >/dev/null 2>&1 9>&- &
fi
