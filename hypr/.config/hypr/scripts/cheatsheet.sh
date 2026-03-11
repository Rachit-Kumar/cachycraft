#!/usr/bin/env bash

## Hyprland + LazyVim Cheatsheet
## Displays keybindings in a searchable Rofi dialog

theme="$HOME/.config/rofi/themes/cheatsheet.rasi"

# Toggle logic
if pgrep -f "rofi.*$theme" > /dev/null; then
    pkill -f "rofi.*$theme"
    exit 0
fi

# ─────────────────────────────────────────────
# Format: "KEY" "DESCRIPTION"   (paired array)
# Headers: key starts with ──
# ─────────────────────────────────────────────
binds=(
"── SESSION & POWER ──────────────────────────────────" ""
"Super + X"               "Open Power Menu (wlogout)"
"Alt + F4"                "Open Power Menu (wlogout)"
"Super + L"               "Lock Screen (Hyprlock)"
"Super + M"               "Exit Hyprland (immediate)"

"── APPLICATIONS ─────────────────────────────────────" ""
"Super + Return"          "Terminal (Kitty)"
"Super + E"               "File Manager (Dolphin)"
"Alt + Space"             "App Launcher (Rofi)"
"Super + V"               "Clipboard History"
"Super + W"               "Wallpaper Selector"
"Super + R"               "Reload Waybar"
"Super + /"               "Open this Cheatsheet"

"── WINDOWS ──────────────────────────────────────────" ""
"Super + C"               "Close Active Window"
"Super + P"               "Pseudo-tile (Dwindle)"
"Super + J"               "Toggle Split (Dwindle)"
"Super + Arrows"          "Move Focus"
"Super + LMB (drag)"      "Move Window"
"Super + RMB (drag)"      "Resize Window"
"Alt + Tab"               "Next Window (Switcher)"
"Alt + Shift + Tab"       "Prev Window (Switcher)"

"── WORKSPACES ───────────────────────────────────────" ""
"Super + 1 … 0"           "Switch to Workspace 1–10"
"Super + Shift + 1 … 0"   "Move Window to Workspace 1–10"
"Super + Scroll"          "Cycle Workspaces"
"Alt + S"                 "Toggle Special Workspace"
"Alt + Shift + S"         "Move to Special Workspace"

"── SCREENSHOTS ──────────────────────────────────────" ""
"Super + Shift + S"       "Capture Region → Clipboard"

"── MEDIA & VOLUME ───────────────────────────────────" ""
"XF86 Vol Up / Down"      "Volume +5% / -5%"
"XF86 Mute"               "Toggle Mute (Audio)"
"XF86 Mic Mute"           "Toggle Mute (Microphone)"
"XF86 Brightness Up / Dn" "Screen Brightness"
"XF86 Next / Prev"        "Next / Prev Track"
"XF86 Play / Pause"       "Play / Pause Media"
"Fn + F5"                 "Cycle Fan Profile"

"── LAZYVIM ──────────────────────────────────────────" ""
"<Space>"                 "Leader Key"
"<Space> f f"             "Find Files (Telescope)"
"<Space> f g"             "Live Grep"
"<Space> f b"             "Browse Buffers"
"<Space> e"               "Toggle File Explorer (Neo-tree)"
"<Space> x x"             "Show Diagnostics"
"<Space> c a"             "Code Action (LSP)"
"g d"                     "Go to Definition"
"g r"                     "Go to References"
"K"                       "Hover Docs (LSP)"
"[ d  /  ] d"             "Prev / Next Diagnostic"
"Ctrl + h/j/k/l"          "Navigate Splits"
"Shift + h / l"           "Prev / Next Buffer"
"<Space> w s"             "Horizontal Split"
"<Space> w v"             "Vertical Split"
"<Space> w q"             "Close Split"
"<Space> q q"             "Quit"
"── Add more via: ~/.config/hypr/scripts/cheatsheet.sh  " ""
)

# ─────────────────────────────────────────────
# Build the Rofi list — NO blank lines between items
# Headers get a distinct visual treatment inline
# ─────────────────────────────────────────────
list_binds() {
    local i=0
    while (( i < ${#binds[@]} )); do
        local key="${binds[i]}"
        local desc="${binds[i+1]}"

        if [[ "$key" == ──* ]]; then
            # Section header row — visually distinct, no leading blank
            printf "  %s\n" "$key"
        elif [[ -n "$desc" ]]; then
            # Normal binding row — key padded to 26 chars, then separator
            printf "  %-26s  │  %s\n" "$key" "$desc"
        fi

        (( i += 2 ))
    done
}

list_binds | rofi -dmenu -p " 󰌌 Search" -theme "$theme" -no-custom -format i
