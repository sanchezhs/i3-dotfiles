#!/bin/bash
# A simple power menu using rofi
# Options: Shutdown, Reboot, Lock, Logout, Suspend, and Hibernate

# Define menu options
options="Shutdown\nReboot\nLock\nLogout\nSuspend\nHibernate"
#options="  Shutdown\n  Reboot\n  Lock\n  Logout\n  Suspend\n   Hibernate"

# Launch rofi in dmenu mode with a prompt.
# You can specify a custom theme by replacing the -theme argument with your theme file.
choice=$(echo -e "$options" | rofi -dmenu -p "Power" -theme ~/.config/i3/powermenu.rasi)

# Execute the corresponding command based on the chosen option.
case "$choice" in
Shutdown)
  # Shutdown the system
  shutdown now
  ;;
Reboot)
  # Reboot the system
  systemctl reboot
  ;;
Lock)
  # Lock the screen. Adjust this command to your preferred locker (e.g. i3lock, betterlockscreen, etc.)
  i3lock -c 000000
  ;;
Logout)
  # Logout of the current session.
  # This example uses i3; change it according to your desktop environment.
  i3-msg exit
  ;;
Suspend)
  # Suspend the system
  systemctl suspend
  ;;
Hibernate)
  # Hibernate the system
  systemctl hibernate
  ;;
*)
  # If no valid option is chosen, exit silently.
  exit 0
  ;;
esac
