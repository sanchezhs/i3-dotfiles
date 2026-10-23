#!/usr/bin/env bash
# Display init on i3 startup: applies the correct profile (by EDID, since
# output names change between boots) and then launches polybar.
LOG=/tmp/display_init.log
{
  echo "=== $(date) display_init ==="
  echo "DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY USER=$USER PATH=$PATH"
  autorandr --change --match-edid 2>&1
  "$HOME/.config/i3/polybar_launch.sh"
  echo "polybar launched; processes:"; pgrep -a polybar
} >"$LOG" 2>&1
