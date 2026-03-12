#!/bin/bash

# ─── Configuration ───
LOG="/tmp/hypr-launch.log"
services=("waybar" "swaync" "hypridle" "swayosd-server" "swww-daemon" "snappy-switcher" "battery-warn")
start_time=$(date +%s%N)

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"
}

is_running() {
    pgrep -x "$1" > /dev/null 2>&1
}

# ─── Parse flags ───
SOFT_MODE=false
if [ "$1" = "--soft" ]; then
    SOFT_MODE=true
    log "=== Soft restart (crashed services only) ==="
else
    log "=== Full desktop restart ==="
fi

# ─── 1. Kill services ───
for service in "${services[@]}"; do
    if is_running "$service"; then
        if [ "$SOFT_MODE" = true ]; then
            log "  ✓ $service already running — skipping"
            continue
        fi
        pkill -f "$service" 2>/dev/null
        log "  ✕ Killed $service"
    else
        log "  ○ $service was not running"
    fi
done

# Wait for processes to settle (skip in soft mode if nothing was killed)
if [ "$SOFT_MODE" = false ]; then
    sleep 0.5
    # Force kill any remaining stubborn processes
    for service in "${services[@]}"; do
        pkill -9 -f "$service" 2>/dev/null
    done
    sleep 0.3
fi

# ─── 2. Start services ───
start_service() {
    local name="$1"
    shift
    if [ "$SOFT_MODE" = true ] && is_running "$name"; then
        return  # already running in soft mode
    fi
    "$@" &
    log "  ▸ Started $name (PID: $!)"
}

start_service "waybar"          waybar
start_service "swaync"          swaync
start_service "hypridle"        hypridle
start_service "swayosd-server"  swayosd-server --top-margin 0.5
start_service "swww-daemon"     swww-daemon
start_service "snappy-switcher" snappy-switcher --daemon
start_service "battery-warn"    "$HOME/.config/hypr/scripts/battery-warn"

# ─── 3. Restore wallpaper ───
sleep 0.5
if [ -f "$HOME/.cache/last_wallpaper" ]; then
    swww img "$(cat "$HOME/.cache/last_wallpaper")" --transition-type none
    log "  ▸ Restored wallpaper"
fi

# ─── 4. Summary ───
sleep 1 # Wait for services to fully settle
end_time=$(date +%s%N)
elapsed_ms=$(( (end_time - start_time) / 1000000 ))
running_count=0
for service in "${services[@]}"; do
    is_running "$service" && running_count=$((running_count + 1))
done

log "=== Done: $running_count/${#services[@]} services active (${elapsed_ms}ms) ==="

if [ "$SOFT_MODE" = true ]; then
    notify-send -a "System" "🔄 Services Checked" "$running_count/${#services[@]} active (${elapsed_ms}ms)"
else
    notify-send -a "System" "✨ Desktop Refreshed" "$running_count/${#services[@]} services restarted (${elapsed_ms}ms)"
fi