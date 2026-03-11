#!/usr/bin/env bash

## Clipboard Manager for Hyprland
## Uses cliphist with rofi premium styling

# Theme directory
theme="$HOME/.config/rofi/themes/cliphist.rasi"

# Toggle logic
if pgrep -f "rofi.*$theme" > /dev/null; then
    pkill -f "rofi.*$theme"
    exit 0
fi

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p " 󱓥 " \
        -theme "${theme}"
}

# Run
cliphist list | rofi_cmd | cliphist decode | wl-copy
