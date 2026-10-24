#!/usr/bin/env bash
# Display init on i3 startup: applies the correct profile (by EDID, since
# output names change between boots). The status bar (i3bar + i3status-rust)
# is managed by i3 itself, so nothing bar-related is launched here.
LOG=/tmp/display_init.log
{
  echo "=== $(date) display_init ==="
  echo "DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY USER=$USER PATH=$PATH"
  autorandr --change --match-edid 2>&1
} >"$LOG" 2>&1
