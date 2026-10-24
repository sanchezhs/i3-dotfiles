#!/usr/bin/env bash
# Wallpaper picker with rofi, showing a grid of thumbnails.
# rofi loads/scales the images itself (via its icon cache), so no thumbnails
# are pre-generated. The chosen image is applied with set-wallpaper.sh.
dir="$HOME/Pictures/wallpapers"

# Build the rofi menu: one row per image, using the image itself as the icon.
# Format per row:  <text>\0icon\x1f<path>   (NUL = 0x00, US = 0x1f)
sel=$(
  find "$dir" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
      -printf '%f\n' | sort |
  while IFS= read -r f; do
    printf '%s\0icon\x1f%s\n' "$f" "$dir/$f"
  done |
  rofi -dmenu -i -p "Wallpaper" -show-icons \
       -theme-str 'window   { width: 900px; }
                   listview { columns: 3; lines: 2; spacing: 14px; }
                   element  { orientation: vertical; padding: 8px; border-radius: 10px; }
                   element-icon { size: 180px; }
                   element-text { horizontal-align: 0.5; }'
)

[ -n "$sel" ] && "$HOME/.config/i3/set-wallpaper.sh" "$dir/$sel"
