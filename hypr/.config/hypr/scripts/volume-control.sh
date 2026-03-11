#!/bin/bash

# Configuration
STEP="0.05"
SINK="@DEFAULT_AUDIO_SINK@"

# 1. Handle commands
case "$1" in
    --up)
        wpctl set-volume -l 1.5 "$SINK" "$STEP"+
        ;;
    --down)
        wpctl set-volume "$SINK" "$STEP"-
        ;;
    --mute)
        wpctl set-mute "$SINK" toggle
        ;;
    --mic-mute)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        ;;
esac

# 2. Get new State
VOL_RAW=$(wpctl get-volume "$SINK")
IS_MUTED=$(echo "$VOL_RAW" | grep -o "\[MUTED\]")
VOL_VAL=$(echo "$VOL_RAW" | awk '{print $2}')

# Convert to percentage and progress using awk (more robust than bc)
PERCENT=$(awk -v v="$VOL_VAL" 'BEGIN {printf "%.0f", v * 100}')
PROGRESS=$(awk -v v="$VOL_VAL" 'BEGIN {print v}')

# 3. Determine Icon
if [ -n "$IS_MUTED" ]; then
    ICON="audio-volume-muted"
    TEXT="Muted"
    PROGRESS=0
else
    TEXT="${PERCENT}%"
    if [ "$PERCENT" -eq 0 ]; then ICON="audio-volume-low";
    elif [ "$PERCENT" -lt 33 ]; then ICON="audio-volume-low";
    elif [ "$PERCENT" -lt 66 ]; then ICON="audio-volume-medium";
    else ICON="audio-volume-high"; fi
fi

# 4. Special case for Mic Mute
if [ "$1" == "--mic-mute" ]; then
    MIC_RAW=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    MIC_MUTED=$(echo "$MIC_RAW" | grep -o "\[MUTED\]")
    if [ -n "$MIC_MUTED" ]; then
        swayosd-client --custom-message "Microphone Muted" --custom-icon "microphone-sensitivity-muted"
    else
        swayosd-client --custom-message "Microphone Active" --custom-icon "microphone-sensitivity-high"
    fi
    exit 0
fi

# 5. Trigger SwayOSD
swayosd-client --custom-progress "$PROGRESS" --custom-progress-text " $TEXT " --custom-icon "$ICON"
