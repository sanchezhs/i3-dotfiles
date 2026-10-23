#!/usr/bin/env bash
# Wallpaper picker with rofi. Lists ~/Pictures/wallpapers and applies the chosen one.
dir="$HOME/Pictures/wallpapers"
sel=$(find "$dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -printf '%f\n' | sort | rofi -dmenu -i -p "Wallpaper")
[ -n "$sel" ] && "$HOME/.config/i3/set-wallpaper.sh" "$dir/$sel"
