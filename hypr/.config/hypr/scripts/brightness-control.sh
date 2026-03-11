#!/bin/bash

# Configuration
BACKLIGHT_DIR="/sys/class/backlight/intel_backlight"
BR_FILE="$BACKLIGHT_DIR/brightness"
MAX_FILE="$BACKLIGHT_DIR/max_brightness"
STEP_PERCENT=5

# 1. Get current values
CURRENT=$(cat "$BR_FILE")
MAX=$(cat "$MAX_FILE")
STEP=$((MAX * STEP_PERCENT / 100))

# 2. Calculate new value
case "$1" in
    --up)
        NEW=$((CURRENT + STEP))
        [ "$NEW" -gt "$MAX" ] && NEW=$MAX
        ;;
    --down)
        NEW=$((CURRENT - STEP))
        [ "$NEW" -lt 0 ] && NEW=0
        ;;
    *)
        exit 1
        ;;
esac

# 3. Apply change
echo "$NEW" > "$BR_FILE"

# 4. Get percentage for OSD
PERCENT=$((NEW * 100 / MAX))
PROGRESS=$(awk -v n="$NEW" -v m="$MAX" 'BEGIN {print n / m}')

# 5. Determine Icon
if [ "$PERCENT" -lt 33 ]; then ICON="brightness-low";
elif [ "$PERCENT" -lt 66 ]; then ICON="brightness-medium";
else ICON="brightness-high"; fi

# 6. Trigger SwayOSD
swayosd-client --custom-progress "$PROGRESS" --custom-progress-text " ${PERCENT}% " --custom-icon "$ICON"
