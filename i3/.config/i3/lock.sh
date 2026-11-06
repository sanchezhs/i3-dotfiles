#!/usr/bin/env bash
# Lock screen themed with the current wallust palette.
# Called by xss-lock (on idle / suspend / `loginctl lock-session`).
# Must stay in the foreground (--nofork) so xss-lock can hold the sleep lock.
#
# Plain i3lock only supports a background color. If i3lock-color (AUR) is
# installed, you also get a blurred screenshot, clock and a themed ring.

colors="$HOME/.config/i3/lock-colors.sh"
# Fallback palette if wallust has not generated the file yet
LOCK_BG='#121517' LOCK_FG='#E8DDC5' LOCK_ACCENT='#81723A'
LOCK_ALERT='#3A4950' LOCK_MUTED='#968B73' LOCK_DIM='#3C4042'
[ -f "$colors" ] && . "$colors"

# i3lock wants RRGGBB / RRGGBBAA without '#'
h() { printf '%s%s' "${1#\#}" "${2:-ff}"; }

if pacman -Qq i3lock-color >/dev/null 2>&1; then
    exec i3lock --nofork --ignore-empty-password --show-failed-attempts \
        --blur 8 \
        --clock --indicator --radius 110 --ring-width 8 \
        --time-str '%H:%M' --date-str '%A, %d %B' \
        --time-color "$(h "$LOCK_FG")" --date-color "$(h "$LOCK_MUTED")" \
        --inside-color "$(h "$LOCK_BG" cc)" --ring-color "$(h "$LOCK_DIM")" \
        --line-uses-inside --separator-color 00000000 \
        --keyhl-color "$(h "$LOCK_ACCENT")" --bshl-color "$(h "$LOCK_ALERT")" \
        --insidever-color "$(h "$LOCK_BG" cc)" --ringver-color "$(h "$LOCK_ACCENT")" \
        --insidewrong-color "$(h "$LOCK_BG" cc)" --ringwrong-color "$(h "$LOCK_ALERT")" \
        --verif-color "$(h "$LOCK_FG")" --wrong-color "$(h "$LOCK_FG")" \
        --verif-text 'checking…' --wrong-text 'wrong' --noinput-text '' \
        --modif-color "$(h "$LOCK_MUTED")"
else
    exec i3lock --nofork --ignore-empty-password --show-failed-attempts \
        --color "$(h "$LOCK_BG" '')"
fi
