#!/bin/bash

# Enhanced Mini Player Script for Waybar (Rofi version)
# Features: Toggle, Progress Bar, Glassmorphism, Top-Alignment, Auto-close, Pin

# 1. Toggle Feature: If already open, close it
if pgrep -x rofi > /dev/null; then
    pkill -x rofi
    exit 0
fi

PLAYER_STATUS=$(playerctl status 2>/dev/null)

if [ -z "$PLAYER_STATUS" ]; then
    notify-send "Mini Player" "No media player active"
    exit 1
fi

# 2. Get Media Info & Clean Up
TITLE=$(playerctl metadata xesam:title | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' | cut -c 1-50)
ARTIST=$(playerctl metadata xesam:artist | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' | cut -c 1-50)
STATUS=$(playerctl status)
POS_SEC=$(playerctl position)
LEN_SEC=$(playerctl metadata mpris:length | awk '{print $1/1000000}')

format_time() {
    local T=$1
    local M=$(( ${T%.*} / 60 ))
    local S=$(( ${T%.*} % 60 ))
    printf "%02d:%02d" $M $S
}

CUR_TIME=$(format_time $POS_SEC)
TOT_TIME=$(format_time $LEN_SEC)

# 3. Create Progress Bar
BAR_SIZE=22
if (( $(echo "$LEN_SEC > 0" | bc -l) )); then
    PROG_PERC=$(echo "scale=2; $POS_SEC / $LEN_SEC" | bc -l)
    FILLED=$(echo "$PROG_PERC * $BAR_SIZE" | bc | cut -d. -f1)
    
    [[ -z "$FILLED" ]] && FILLED=0
    ((FILLED < 0)) && FILLED=0
    ((FILLED > BAR_SIZE)) && FILLED=$BAR_SIZE
    
    BAR_BEFORE=""
    BAR_AFTER=""
    for ((i=0; i<BAR_SIZE; i++)); do
        if [ $i -lt $FILLED ]; then
            BAR_BEFORE="${BAR_BEFORE}━"
        elif [ $i -gt $FILLED ]; then
            BAR_AFTER="${BAR_AFTER}━"
        fi
    done
    BAR="<span color='#61afef' weight='bold'>$BAR_BEFORE</span><span color='#ffffff' weight='bold'>◯</span><span color='#4b5263' weight='bold'>$BAR_AFTER</span>"
else
    BAR="<span color='#4b5263' weight='bold'>━━━━━━━━━━━━━━━━━━━━━━━</span>"
fi

# 4. Menu Content
PLAY_ICON="󰐊 Play / Pause"
NEXT_ICON="󰒭 Next Track"
PREV_ICON="󰒮 Previous Track"
MUTE_ICON="󰝟 Mute Toggle"
PIN_ICON=" Pin Player (Disable Auto-close)"

MENU_CONTENT="$PLAY_ICON\n$NEXT_ICON\n$PREV_ICON\n$MUTE_ICON\n$PIN_ICON"

# 5. Rofi Theme
ROFI_THEME="
* {
    blue: #61afef;
    fg: #abb2bf;
    bg: rgba(33, 37, 43, 0.9);
    border-col: rgba(171, 178, 191, 0.2);
}
window {
    location:       north; anchor: north;
    y-offset:       60px;  x-offset: 0px;
    width:          520px;
    background-color: @bg;
    border: 1px; border-color: @border-col; border-radius: 20px;
}
mainbox { background-color: transparent; padding: 25px; children: [ \"message\", \"listview\" ]; }
message { background-color: transparent; padding: 0 0 20px 0; }
textbox { text-color: @fg; background-color: transparent; vertical-align: 0.5; horizontal-align: 0.5; markup: true; }
listview { background-color: transparent; lines: 5; spacing: 8px; fixed-height: true; }
element { background-color: transparent; padding: 10px; border-radius: 12px; }
element selected { background-color: rgba(97, 175, 239, 0.1); text-color: @blue; }
element-text { background-color: transparent; text-color: inherit; font: \"CaskaydiaCove Nerd Font 12\"; }
"

# 6. Build Message
MSG="<span size='large' weight='bold' color='#61afef'>$TITLE</span>\n<span size='medium' color='#abb2bf'>$ARTIST</span>\n\n<span font='10'>$CUR_TIME   $BAR   $TOT_TIME</span>"

# 7. Robust Auto-close Logic
# We run a background shell that waits and then kills rofi
if [[ "$1" != "--pinned" ]]; then
    (sleep 6 && pkill -x rofi) &
fi

# 8. Show Menu
CHOICE=$(echo -e "$MENU_CONTENT" | rofi -dmenu -i \
    -mesg "$(echo -e "$MSG")" \
    -theme-str "$ROFI_THEME")

case "$CHOICE" in
    *"Play"*) playerctl play-pause ;;
    *"Next"*) playerctl next ;;
    *"Previous"*) playerctl previous ;;
    *"Mute"*) amixer set Master toggle ;;
    *"Pin"*) exec "$0" --pinned ;;
esac
