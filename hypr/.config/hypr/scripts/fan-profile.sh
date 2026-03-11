#!/bin/bash

# Function to get current profile
get_profile() {
    powerprofilesctl get
}

# Function to set profile and notify
set_profile() {
    local profile=$1
    powerprofilesctl set "$profile"
    
    # Trigger SwayOSD for visual feedback
    case "$profile" in
        "power-saver")
            swayosd-client --custom-message "Quiet Mode" --custom-icon "fan-selection-low"
            ;;
        "balanced")
            swayosd-client --custom-message "Balanced Mode" --custom-icon "fan-selection-medium"
            ;;
        "performance")
            swayosd-client --custom-message "Performance Mode" --custom-icon "fan-selection-high"
            ;;
    esac
    
    # Signal waybar to refresh
    pkill -SIGRTMIN+8 waybar
}

# 1. Toggle Mode
if [ "$1" == "--toggle" ]; then
    CURRENT=$(get_profile)
    case "$CURRENT" in
        "performance") set_profile "power-saver" ;;
        "power-saver") set_profile "balanced" ;;
        "balanced")    set_profile "performance" ;;
        *)             set_profile "balanced" ;;
    esac
    exit 0
fi

# 2. Waybar Output Mode (Default)
PROFILE=$(get_profile)
case "$PROFILE" in
    "power-saver")
        echo '{"text": "󰈐 Quiet", "class": "quiet"}'
        ;;
    "balanced")
        echo '{"text": " Balanced", "class": "balanced"}'
        ;;
    "performance")
        echo '{"text": "󰓅 Perform..", "class": "performance"}'
        ;;
    *)
        echo "{\"text\": \"󰈐 $PROFILE\", \"class\": \"unknown\"}"
        ;;
esac