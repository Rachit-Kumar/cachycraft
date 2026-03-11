<p align="center">
  <img src="https://cachyos.org/wp-content/uploads/elementor/thumbs/Logo_1-q1w60p9mz1ddvvihp2cxjxuusgnojsz8hx1o0hsjao.png" width="80" />
</p>

<h1 align="center">🍚 cachy-dots</h1>

<p align="center">
  <b>Hyprland rice on CachyOS — managed with GNU Stow</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/OS-CachyOS-00c4b4?style=flat-square&logo=archlinux&logoColor=white" />
  <img src="https://img.shields.io/badge/WM-Hyprland-58e1ff?style=flat-square&logo=wayland&logoColor=white" />
  <img src="https://img.shields.io/badge/Shell-Fish-ffb347?style=flat-square&logo=gnu-bash&logoColor=white" />
  <img src="https://img.shields.io/badge/Terminal-Kitty-7C3AED?style=flat-square" />
  <img src="https://img.shields.io/badge/Dotfiles-GNU_Stow-green?style=flat-square" />
</p>

---

## 🖥️ System Info

| Component | Details |
|:---|:---|
| **OS** | CachyOS (Arch-based, rolling) |
| **Kernel** | 6.19.x-cachyos |
| **WM** | Hyprland 0.54.x |
| **Bar** | Waybar |
| **Terminal** | Kitty (+ Alacritty as backup) |
| **Shell** | Fish |
| **Launcher** | Rofi (Wayland fork) |
| **Notifications** | SwayNC |
| **Wallpaper** | swww + custom selector |
| **Theming** | Matugen (dynamic Material You) |
| **Lock Screen** | Hyprlock |
| **Idle** | Hypridle |
| **Logout** | wlogout |
| **GTK Theme** | adw-gtk3-dark |
| **Icons** | Gruvbox-Plus-Dark |
| **Cursor** | Layan-white-cursors |
| **Font** | CaskaydiaCove Nerd Font Mono |

---

## 📦 Stow Packages

Dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/). Each folder is a self-contained package that mirrors `$HOME`.

```
~/.dotfiles/
├── hypr/          # Hyprland config, scripts, appearance, keybindings
├── waybar/        # Status bar layout + modules
├── rofi/          # App launcher, clipboard, wallpaper themes
├── fish/          # Shell config, abbreviations, prompt
├── kitty/         # Primary terminal config + colors
├── alacritty/     # Backup terminal config
├── swaync/        # Notification center styling
├── wlogout/       # Power menu layout + styling
├── btop/          # System monitor config
├── fastfetch/     # System info display
├── swayosd/       # On-screen display for vol/brightness
├── hyprlock/      # Lock screen config
├── gtk/           # GTK 2/3/4 theme, fonts, icons, cursor
└── misc/          # Wallpaper dirs, favorites, gestures, mime
```

---

## ⌨️ Keybindings

| Key | Action |
|:---|:---|
| `Super + Return` | Kitty terminal |
| `Super + C` | Close window |
| `Super + F` | Toggle fullscreen |
| `Super + T` | Toggle floating |
| `Super + G` | Toggle window group |
| `Super + W` | Wallpaper selector |
| `Super + V` | Clipboard |
| `Super + /` | Cheatsheet |
| `Super + L` | Lock screen |
| `Super + X` | Power menu |
| `Super + R` | Refresh services |
| `Alt + Space` | App launcher |
| `Alt + Tab` | Window switcher |
| `Super + Shift + S` | Screenshot (region) |
| `Super + Shift + Arrow` | Move window to monitor |
| `Super + Shift + P` | Pin window (always-on-top) |
| `Super + 1-0` | Switch workspace |
| `Super + Shift + 1-0` | Move window to workspace |

---

## 🚀 Scripts

All custom logic lives in `hypr/.config/hypr/scripts/`:

| Script | Purpose |
|:---|:---|
| `launch.sh` | Restart services (`--soft` = only crashed ones). Logs to `/tmp/hypr-launch.log` |
| `wallpaper-selector.sh` | Grid picker with favorites, random, multi-folder support |
| `volume-control.sh` | Volume + SwayOSD visuals |
| `brightness-control.sh` | Brightness via sysfs |
| `fan-profile.sh` | ASUS fan/power profile toggle |
| `clipboard.sh` | cliphist integration |
| `cheatsheet.sh` | Keybinding reference |
| `mini-player.sh` | MPRIS music widget |

---

## 🐚 Fish Shell

Pre-configured with useful abbreviations:

```
gs  → git status       ll  → eza -la --icons
gc  → git commit       lt  → eza --tree
gp  → git push         cat → bat
glog → git log graph   pacu → sudo pacman -Syu
reload → hyprctl reload
```

---

## ⚡ Installation

> **Warning:** These are *my* personal dotfiles. Review before applying — they will overwrite your existing configs.

### Prerequisites

```bash
# Core
sudo pacman -S hyprland waybar rofi-wayland swaync swww hyprlock hypridle wlogout

# Terminals & Shell
sudo pacman -S kitty fish

# Tools
sudo pacman -S stow eza bat cliphist playerctl swayosd matugen

# Fonts & Themes
sudo pacman -S ttf-cascadia-code-nerd adw-gtk3-dark gruvbox-plus-icon-theme
yay -S layan-cursor-theme-git
```

### Deploy

```bash
git clone https://github.com/<username>/cachy-dots.git ~/.dotfiles
cd ~/.dotfiles

# Stow all packages (creates symlinks into ~/.config)
for pkg in */; do stow "$pkg"; done

# Reload Hyprland
hyprctl reload
```

### Unstow (remove symlinks)

```bash
cd ~/.dotfiles
stow -D <package-name>   # e.g. stow -D hypr
```

---

## 🎨 Wallpaper System

- Press `Super + W` to open the wallpaper grid
- Wallpapers are auto-themed using **Matugen** (Material You colors)
- Add folders: edit `~/.config/wallpaper-dirs` or click 📁 in the selector
- Favorites, random mode, and category browsing included

---

## 📝 License

Feel free to use, modify, and share. Attribution appreciated but not required.

---

<p align="center">
  <sub>🍚 Riced with ❤️ on CachyOS</sub>
</p>
