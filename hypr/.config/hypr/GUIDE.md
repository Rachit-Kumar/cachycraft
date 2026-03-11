# 🪞 Rachit's Tier 1 Hyprland Guide

Welcome to your modular and organized configuration! This guide explains how everything is structured so you can easily manage and customize your desktop.

---

## 📂 Directory Structure

### 1. Hyprland Hub (`~/.config/hypr/`)
- **`hyprland.conf`**: The main entry point — only `source` links to modular configs.
- **`configs/`**: The heart of your settings.
  - `monitors.conf`: Display resolutions and refresh rates.
  - `variables.conf`: Default apps ($terminal, $fileManager).
  - `env.conf`: Environment variables (cursor, GTK/QT themes).
  - `autostart.conf`: Apps that launch on login.
  - `appearance.conf`: Gaps, borders, animations, and blur.
  - `input.conf`: Keyboard, mouse, and touchpad settings.
  - `keybindings.conf`: All your keyboard shortcuts.
  - `rules.conf`: Window and Workspace rules.
  - `hyprlock.conf` & `hypridle.conf`: Lock screen and power management.
- **`scripts/`**: **The Master Brain** — all custom logic scripts.

### 2. Waybar (`~/.config/waybar/`)
- **`config.jsonc`**: Bar layout and which modules are shown.
- **`configs/modules.jsonc`**: Module behavior (Clock, Battery, Music, etc.).

### 3. Rofi (`~/.config/rofi/`)
- **`themes/`**: Custom `.rasi` files for Clipboard, Cheatsheet, Wallpaper, and Power Menu.
- **`shared/colors.rasi`**: Master color palette used by all Rofi themes.

### 4. Wallpaper System
- **`~/.config/wallpaper-dirs`**: List of wallpaper directories (one per line).
- **`~/.config/wallpaper-favorites`**: Your starred wallpapers.

### 5. GTK Theme (`~/.config/gtk-3.0/`, `gtk-4.0/`, `gtkrc-2.0`)
- All three GTK versions are synced: `adw-gtk3-dark` theme, `Gruvbox-Plus-Dark` icons, `Layan-white-cursors` cursor, `CaskaydiaCove Nerd Font Mono` font.

---

## ⌨️ Keybindings

| Keybinding | Action |
| :--- | :--- |
| `Super + Return` | Open terminal (Kitty) |
| `Super + C` | Close active window |
| `Super + E` | File manager (Dolphin) |
| `Super + F` | Toggle fullscreen |
| `Super + T` | Toggle floating |
| `Super + G` | Toggle window group |
| `Super + Shift + P` | Pin floating window (always-on-top) |
| `Super + W` | Wallpaper selector |
| `Super + V` | Clipboard manager |
| `Super + /` | Cheatsheet |
| `Super + R` | Refresh all services |
| `Super + L` | Lock screen |
| `Super + X` / `Alt + F4` | Power menu |
| `Alt + Space` | App launcher (Rofi) |
| `Alt + Tab` | Window switcher |
| `Super + Shift + S` | Screenshot (region) |
| `Super + Shift + Arrow` | Move window to adjacent monitor |
| `Fn + F6` | Screenshot (hardware macro) |

---

## 🚀 The Master Brain (`~/.config/hypr/scripts/`)

| Script | Purpose |
| :--- | :--- |
| `launch.sh` | Restart all services. Supports `--soft` flag (only restart crashed services). Logs to `/tmp/hypr-launch.log`. |
| `wallpaper-selector.sh` | Wallpaper grid with favorites, random mode, and multi-folder support. |
| `volume-control.sh` | Audio control with SwayOSD visualization. |
| `brightness-control.sh` | Screen brightness via sysfs. |
| `fan-profile.sh` | Toggle power/fan profiles (ASUS). |
| `clipboard.sh` | Clipboard history via `cliphist`. |
| `cheatsheet.sh` | Formats and displays your keybindings. |
| `mini-player.sh` | MPRIS-based music player widget. |

---

## 🐚 Fish Shell (`~/.config/fish/`)
- **Abbreviations**: Type `gs`, `gc`, `gp`, `ll`, `lt`, `cat`, etc. and they expand on Enter.
- **`$EDITOR`**: Set to `nano`.
- **Custom prompt**: Two-line prompt with git status and error highlighting.

---

## 🛠️ Maintenance & Tips

- **Adding a Keybinding**: Edit `~/.config/hypr/configs/keybindings.conf`.
- **Changing Colors**: Edit `~/.config/rofi/shared/colors.rasi` to update all dialogs.
- **Adding Wallpaper Folders**: Edit `~/.config/wallpaper-dirs` (or press 📁 in the wallpaper selector).
- **Reloading Config**: Most Hyprland changes apply on save. Manual: `hyprctl reload`.
- **Soft Restart**: Run `~/.config/hypr/scripts/launch.sh --soft` to restart only crashed services.
- **Debugging**: Check scripts in `~/.config/hypr/scripts/` — ensure `chmod +x`.
- **Launch Log**: View `cat /tmp/hypr-launch.log` for service status.

---
*Created with ❤️ by Antigravity*
