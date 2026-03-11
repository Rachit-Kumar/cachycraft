#!/usr/bin/env bash

## Power Menu for Hyprland
## Uses rofi with premium styling and confirmation dialogs

# Theme directory
dir="$HOME/.config/rofi/powermenu"
theme="powermenu"

# System info
uptime_info="$(uptime -p | sed -e 's/up //g')"
host="$(hostname)"
user="$(whoami)"

# Options with icons
shutdown="  Shutdown"
reboot="  Reboot"
lock="  Lock"
suspend="󰤄  Sleep"
logout="󰍃  Logout"

# Confirmation options
yes=" Yes"
no=" No"

# Rofi CMD with premium theme
rofi_cmd() {
    rofi -dmenu \
        -p " $user@$host" \
        -mesg "  Uptime: $uptime_info" \
        -theme "${dir}/${theme}.rasi"
}

# Confirmation CMD
confirm_cmd() {
    rofi -dmenu \
        -p " Confirm" \
        -mesg "  Are you sure?" \
        -theme "${dir}/${theme}.rasi" \
        -theme-str 'window { width: 350px; }' \
        -theme-str 'listview { columns: 2; lines: 1; }' \
        -theme-str 'element-text { horizontal-align: 0.5; }' \
        -theme-str 'inputbar { children: [ "textbox-prompt-colon", "prompt" ]; }' \
        -theme-str 'textbox { horizontal-align: 0.5; }'
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute with confirmation
run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        case "$1" in
            --shutdown)
                systemctl poweroff
                ;;
            --reboot)
                systemctl reboot
                ;;
            --suspend)
                playerctl -a pause 2>/dev/null
                amixer set Master mute 2>/dev/null
                systemctl suspend
                ;;
            --logout)
                hyprctl dispatch exit 2>/dev/null || loginctl terminate-user "$USER"
                ;;
        esac
    fi
}

# Main
chosen="$(run_rofi)"
case "${chosen}" in
    "$shutdown")
        run_cmd --shutdown
        ;;
    "$reboot")
        run_cmd --reboot
        ;;
    "$lock")
        # Try common lock screens
        if command -v hyprlock &>/dev/null; then
            hyprlock
        elif command -v swaylock &>/dev/null; then
            swaylock -f
        elif command -v betterlockscreen &>/dev/null; then
            betterlockscreen -l
        else
            notify-send "Power Menu" "No screen locker found"
        fi
        ;;
    "$suspend")
        run_cmd --suspend
        ;;
    "$logout")
        run_cmd --logout
        ;;
esac
