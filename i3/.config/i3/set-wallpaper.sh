#!/usr/bin/env bash
# Applies a wallpaper: generates the theme (wallust) and reloads the apps.
# Usage: set-wallpaper.sh /path/to/image.jpg
img="$1"
[ -f "$img" ] || { notify-send "Wallpaper" "Not found: $img" 2>/dev/null; exit 1; }

# Remember it as the current one (used by i3 startup and the autorandr postswitch)
ln -sf "$img" "$HOME/.config/wallpaper.current"

# 1) Palette from the image + fill templates (alacritty/polybar/dunst/rofi/i3)
wallust run "$img" >/dev/null 2>&1

# 2) Background on all screens
xwallpaper --zoom "$img"

# 3) Reload what does not update on its own
#    alacritty -> live_config_reload (automatic)
#    rofi      -> re-reads its theme on each open (automatic)
dunstctl reload 2>/dev/null                 # notifications
i3-msg reload >/dev/null 2>&1               # i3 window borders (does not relaunch apps)
"$HOME/.config/i3/polybar_launch.sh"        # bar
