# i3-dotfiles

Dotfiles for my MSI laptop (Intel Raptor Lake + NVIDIA RTX 4060, hybrid
graphics) running **Arch Linux + i3**. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

| Package (stow) | What it is |
|---|---|
| `i3` | i3 WM + scripts (display init, polybar launcher, wallpaper picker) |
| `polybar` | Status bar (dynamic colors via wallust) |
| `alacritty` | Terminal (dynamic theme via wallust) |
| `rofi` | Launcher (dynamic theme via wallust) |
| `wallust` | Dynamic theming: generates palettes from the wallpaper and fills templates |
| `autorandr` | Display profiles + HDMI hotplug (specific to this machine) |

`dunst` is not a package: its `dunstrc` is generated entirely by wallust.

## Dependencies

```sh
sudo pacman -S i3-wm polybar alacritty rofi dunst xwallpaper autorandr \
               picom network-manager-applet lightdm lightdm-slick-greeter \
               ttf-jetbrains-mono-nerd
yay -S wallust            # AUR
# Extras used: tlp (power), batsignal (battery alerts), stow
sudo pacman -S tlp stow && yay -S batsignal
```

## Installation (on a new machine)

```sh
git clone https://github.com/sanchezhs/i3-dotfiles ~/dotfiles
cd ~/dotfiles
stow i3 polybar alacritty rofi wallust autorandr
```

`stow <package>` creates the symlinks (`~/.config/i3` -> `~/dotfiles/i3/.config/i3`, etc.).
If a target already exists as a real file, move/remove it first or use `stow --adopt`.

### Theme bootstrap (first run)

Color files are in `.gitignore` (they are regenerated). Generate the theme once:

```sh
mkdir -p ~/Pictures/wallpapers           # put your wallpapers here
ln -sf ~/Pictures/wallpapers/YOUR_WALL.jpg ~/.config/wallpaper.current
wallust run ~/.config/wallpaper.current  # generates colors for every app
```

Then, inside i3, **`Mod+Shift+w`** opens a picker (rofi) to change the wallpaper:
it sets the background and regenerates the theme for the terminal, polybar, dunst,
rofi and i3 borders all at once.

## System changes (`system/`)

The `system/` folder is NOT installed with stow; these are reference copies of
`/etc` to restore the system configuration after a reinstall:

- `etc/mkinitcpio.conf` — `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`
  so NVIDIA loads early and the greeter doesn't fail at boot. After copying:
  `sudo mkinitcpio -P`.
- `etc/modprobe.d/nvidia.conf` — `modeset=1`.
- `etc/modprobe.d/nvidia-power.conf` — `NVreg_PreserveVideoMemoryAllocations=1`
  (stable suspend). Enable: `sudo systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume`.
- `etc/pacman.d/hooks/nvidia.hook` — regenerates the initramfs on NVIDIA upgrades.
- `etc/systemd/system/autorandr.service.d/match-edid.conf` — autorandr matches by
  EDID (output names change between boots on hybrid graphics).

Also, on the kernel command line: `nvidia-drm.modeset=1`.

## Configuration notes

- **Displays**: output names shift between boots (`eDP-1`/`eDP-2`), so everything
  matches by EDID (`autorandr --match-edid`) and polybar detects monitors by role
  (internal `eDP*` / external `HDMI*`), never by a fixed name.
- **HDMI hotplug**: `autorandr` via udev + `~/.config/autorandr/postswitch`
  (repaints the wallpaper and relaunches polybar).
- `Mod+Shift+r` (restart) reapplies everything; `Mod+Shift+c` (reload) does NOT
  re-run the `exec_always` lines.
