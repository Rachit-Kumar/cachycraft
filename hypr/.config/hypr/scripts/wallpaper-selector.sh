#!/bin/bash

# Toggle logic
if pgrep -f "rofi.*grid.rasi" > /dev/null; then
    pkill -f "rofi.*grid.rasi"
    exit 0
fi

# ─── Configuration ───
DEFAULT_DIR="$HOME/Pictures/Wallpapers/All"
DIRS_CONFIG="$HOME/.config/wallpaper-dirs"
CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"
THUMBNAIL_DIR="$HOME/Pictures/Thumbnails"
FAVORITES_FILE="$HOME/.config/wallpaper-favorites"
LAST_WALLPAPER_FILE="$HOME/.cache/last_wallpaper"
HISTORY_FILE="$HOME/.cache/wallpaper-history"

mkdir -p "$CACHE_DIR"
mkdir -p "$THUMBNAIL_DIR"
touch "$FAVORITES_FILE"
touch "$HISTORY_FILE"

# Create dirs config with default if it doesn't exist
if [ ! -f "$DIRS_CONFIG" ]; then
    echo "# Wallpaper directories (one per line)" > "$DIRS_CONFIG"
    echo "# Lines starting with # are ignored" >> "$DIRS_CONFIG"
    echo "$DEFAULT_DIR" >> "$DIRS_CONFIG"
fi

# ─── Load all wallpaper directories ───
get_wallpaper_dirs() {
    local dirs=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [ -z "$line" ] && continue
        # Expand ~ and env vars
        line=$(eval echo "$line" 2>/dev/null)
        [ -d "$line" ] && dirs+=("$line")
    done < "$DIRS_CONFIG"
    # Fallback to default if no valid dirs
    if [ ${#dirs[@]} -eq 0 ]; then
        dirs=("$DEFAULT_DIR")
    fi
    printf '%s\n' "${dirs[@]}"
}

# ─── Transition styles ───
TRANSITIONS=("grow" "wipe" "wave" "outer")
get_random_transition() {
    echo "${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}"
}

# ─── Thumbnail generation (parallel) — scans all dirs ───
generate_thumbnails() {
    local dirs
    mapfile -t dirs < <(get_wallpaper_dirs)
    for dir in "${dirs[@]}"; do
        find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.webm" \) | \
        xargs -P 4 -I{} bash -c '
            img="$1"
            cache_dir="$2"
            filename=$(basename "$img")
            thumbnail="$cache_dir/${filename%.*}.png"
            if [ ! -f "$thumbnail" ] || [ "$img" -nt "$thumbnail" ]; then
                magick "$img[0]" -resize 300x300^ -gravity center -extent 300x300 +adjoin "$thumbnail" 2>/dev/null
            fi
        ' _ {} "$CACHE_DIR"
    done
}

# ─── Video thumbnail generation (parallel) — scans all dirs ───
generate_video_thumbnails() {
    local dirs
    mapfile -t dirs < <(get_wallpaper_dirs)
    for dir in "${dirs[@]}"; do
        find "$dir" -type f -iname "*.mp4" | \
        xargs -P 4 -I{} bash -c '
            video="$1"
            thumb_dir="$2"
            cache_dir="$3"
            filename=$(basename "$video")
            full_thumbnail="$thumb_dir/${filename%.*}.jpg"
            small_thumbnail="$cache_dir/${filename%.*}.png"
            if [ ! -f "$full_thumbnail" ] || [ "$video" -nt "$full_thumbnail" ]; then
                ffmpeg -i "$video" -vframes 1 -q:v 2 "$full_thumbnail" -y 2>/dev/null
            fi
            if [ -f "$full_thumbnail" ]; then
                if [ ! -f "$small_thumbnail" ] || [ "$full_thumbnail" -nt "$small_thumbnail" ]; then
                    magick "$full_thumbnail" -resize 300x300^ -gravity center -extent 300x300 "$small_thumbnail" 2>/dev/null
                fi
            fi
        ' _ {} "$THUMBNAIL_DIR" "$CACHE_DIR"
    done
}

# ─── Apply wallpaper theme using matugen (accent picker commented out) ───
generate_wallpaper_theme() {
    local thumbnail_path="$1"

    # Apply matugen theme directly with image colors (no accent picker)
    matugen image "$thumbnail_path" 2>/dev/null

    # ─── Accent color selector (commented out) ───
    # Uncomment the block below to re-enable manual accent color picking via rofi.
    #
    # local color_cache_dir="$HOME/.cache/hexcolors"
    # mkdir -p "$color_cache_dir"
    # rm -f "$color_cache_dir"/*.png
    #
    # local colors=$(matugen -d image "$thumbnail_path" 2>&1 | grep -oP '#[0-9a-fA-F]{6}' | tr -d '#' | sort -u)
    #
    # while read -r hex; do
    #     [ -z "$hex" ] && continue
    #     magick -size 128x128 xc:"#$hex" "$color_cache_dir/$hex.png"
    # done <<< "$colors"
    #
    # local selected=$(find "$color_cache_dir" -name "*.png" | while read -r icon_path; do
    #     local name=$(basename "$icon_path" .png)
    #     echo -en "#$name\0icon\x1f$icon_path\n"
    # done | rofi -dmenu -i -p " Accent" \
    #     -mesg "  Pick an accent color for your theme" \
    #     -theme ~/.config/rofi/themes/grid-colors.rasi \
    #     -show-icons \
    #     -theme-str 'element-icon { size: 6em; }')
    #
    # [ -n "$selected" ] && matugen color hex "$selected"

    local transition=$(get_random_transition)
    swww img "$thumbnail_path" \
        --transition-type "$transition" \
        --transition-pos 0.5,0.5 \
        --transition-duration 1.5 \
        --transition-fps 60 \
        --transition-bezier "0.68,-0.55,0.27,1.55" \
        --transition-step 60
}

# ─── Favorites management ───
is_favorite() {
    grep -qxF "$1" "$FAVORITES_FILE" 2>/dev/null
}

toggle_favorite() {
    local wallpaper="$1"
    if is_favorite "$wallpaper"; then
        grep -vxF "$wallpaper" "$FAVORITES_FILE" > "$FAVORITES_FILE.tmp"
        mv "$FAVORITES_FILE.tmp" "$FAVORITES_FILE"
        notify-send -a "Wallpaper" "★ Removed from Favorites" "$wallpaper"
    else
        echo "$wallpaper" >> "$FAVORITES_FILE"
        notify-send -a "Wallpaper" "★ Added to Favorites" "$wallpaper"
    fi
}

# ─── Get current wallpaper ───
get_current_wallpaper() {
    if [ -f "$LAST_WALLPAPER_FILE" ]; then
        basename "$(cat "$LAST_WALLPAPER_FILE")" 2>/dev/null
    fi
}

# ─── Add to history ───
add_to_history() {
    local wallpaper="$1"
    grep -vxF "$wallpaper" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" 2>/dev/null
    { echo "$wallpaper"; cat "$HISTORY_FILE.tmp"; } | head -50 > "$HISTORY_FILE"
    rm -f "$HISTORY_FILE.tmp"
}

# ─── Resolve a relative wallpaper name to its full path ───
resolve_wallpaper_path() {
    local name="$1"
    local dirs
    mapfile -t dirs < <(get_wallpaper_dirs)
    for dir in "${dirs[@]}"; do
        local full="$dir/$name"
        [ -f "$full" ] && echo "$full" && return 0
    done
    return 1
}

# ─── Start thumbnail generation in background ───
if command -v magick &> /dev/null || command -v convert &> /dev/null; then
    generate_thumbnails &
fi
if command -v ffmpeg &> /dev/null; then
    generate_video_thumbnails &
fi

# ─── Build rofi entries ───
build_menu() {
    local current_wp=$(get_current_wallpaper)
    local show_mode="$1"  # "all" or "favorites"

    # Top-level action buttons
    if [ "$show_mode" = "all" ]; then
        echo -en "★ Favorites\0icon\x1fuser-bookmarks\n"
        echo -en "🎲 Random\0icon\x1fmedia-playlist-shuffle\n"
        echo -en "📁 Manage Folders\0icon\x1ffolder-open\n"
    else
        echo -en "◀ Back to All\0icon\x1fgo-previous\n"
    fi

    local wallpapers
    if [ "$show_mode" = "favorites" ]; then
        wallpapers=$(cat "$FAVORITES_FILE" 2>/dev/null)
    else
        # Collect wallpapers from all configured directories
        local dirs
        mapfile -t dirs < <(get_wallpaper_dirs)
        wallpapers=""
        for dir in "${dirs[@]}"; do
            local dir_label=$(basename "$dir")
            local found
            found=$(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.mp4" \) -printf "%P\n" | sort)
            if [ -n "$found" ]; then
                # If there are multiple dirs, prefix with directory label
                if [ ${#dirs[@]} -gt 1 ]; then
                    wallpapers+=$(echo "$found" | sed "s|^|$dir_label/|")
                    wallpapers+=$'\n'
                else
                    wallpapers+="$found"
                    wallpapers+=$'\n'
                fi
            fi
        done
    fi

    echo "$wallpapers" | while read -r wallpaper; do
        [ -z "$wallpaper" ] && continue
        local filename=$(basename "$wallpaper")
        local name_without_ext="${filename%.*}"
        thumbnail="$CACHE_DIR/${name_without_ext}.png"

        # Build display name with indicators
        local display_name="$wallpaper"
        if [ "$filename" = "$current_wp" ] || [ "$wallpaper" = "$current_wp" ]; then
            display_name="✓ $wallpaper"
        fi
        if is_favorite "$wallpaper"; then
            display_name="★ $display_name"
        fi

        if [ -f "$thumbnail" ]; then
            printf "%s\0icon\x1f%s\n" "$display_name" "$thumbnail"
        else
            echo "$display_name"
        fi
    done
}

# ─── Get all wallpapers (for random mode) — from all dirs ───
get_wallpapers() {
    local dirs
    mapfile -t dirs < <(get_wallpaper_dirs)
    for dir in "${dirs[@]}"; do
        find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.mp4" \) -printf "%P\n"
    done
}

# ─── Run selector with a given mode (direct apply, no sub-menu) ───
run_selector() {
    local mode="$1"  # "all" or "favorites"

    local prompt=" Wallpaper"
    local mesg_prefix=""
    if [ "$mode" = "favorites" ]; then
        prompt="★ Favorites"
        local fav_count=$(wc -l < "$FAVORITES_FILE" 2>/dev/null || echo 0)
        mesg_prefix="  $fav_count favorites"
    else
        local total=0
        local dirs
        mapfile -t dirs < <(get_wallpaper_dirs)
        for dir in "${dirs[@]}"; do
            local count=$(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.mp4" \) 2>/dev/null | wc -l)
            total=$((total + count))
        done
        local dir_count=${#dirs[@]}
        if [ "$dir_count" -gt 1 ]; then
            mesg_prefix="  $total wallpapers from $dir_count folders"
        else
            mesg_prefix="  $total wallpapers"
        fi
    fi

    local raw_selected=$(build_menu "$mode" | rofi -dmenu -i -p "$prompt" \
        -mesg "$mesg_prefix" \
        -show-icons \
        -theme ~/.config/rofi/themes/grid.rasi \
        -theme-str 'element-icon { size: 6em; }' \
        -me-select-entry '' -me-accept-entry MousePrimary)

    [ -z "$raw_selected" ] && exit 0

    # Handle top-level action buttons
    case "$raw_selected" in
        "★ Favorites")
            run_selector "favorites"
            return
            ;;
        "🎲 Random")
            mapfile -t wallpapers < <(get_wallpapers)
            selected="${wallpapers[$RANDOM % ${#wallpapers[@]}]}"
            return
            ;;
        "◀ Back to All")
            run_selector "all"
            return
            ;;
        "📁 Manage Folders")
            local editor="${EDITOR:-nano}"
            # Open in terminal for editing
            if command -v kitty &>/dev/null; then
                kitty --title "Wallpaper Folders" -- $editor "$DIRS_CONFIG"
            elif command -v alacritty &>/dev/null; then
                alacritty --title "Wallpaper Folders" -e $editor "$DIRS_CONFIG"
            else
                notify-send -a "Wallpaper" "📁 Config File" "$DIRS_CONFIG\nEdit this file to add/remove folders."
            fi
            return
            ;;
    esac

    # Clean indicators from selection and apply directly
    selected=$(echo "$raw_selected" | sed 's/^[★✓ ]*//' | tr -d '\0')
}

# ─── Main selection logic ───
if [ "$1" = "random" ]; then
    mapfile -t wallpapers < <(get_wallpapers)
    if [ ${#wallpapers[@]} -eq 0 ]; then
        notify-send -a "Wallpaper" "Error" "No wallpapers found"
        exit 1
    fi
    selected="${wallpapers[$RANDOM % ${#wallpapers[@]}]}"

elif [ "$1" = "favorites" ]; then
    run_selector "favorites"

else
    run_selector "all"
fi

# ─── Set wallpaper ───
if [ -n "$selected" ]; then
    # Clean indicators from selection
    selected=$(echo "$selected" | sed 's/^[★✓ ]*//' | tr -d '\0')

    # Resolve the full path — try each configured directory
    wallpaper_path=$(resolve_wallpaper_path "$selected")

    # If multi-dir label was prepended (e.g. "DirName/file.jpg"), try stripping it
    if [ -z "$wallpaper_path" ]; then
        # The label is the dir basename, try matching against actual dirs
        mapfile -t _dirs < <(get_wallpaper_dirs)
        for dir in "${_dirs[@]}"; do
            dir_label=$(basename "$dir")
            if [[ "$selected" == "$dir_label/"* ]]; then
                relative="${selected#$dir_label/}"
                full="$dir/$relative"
                if [ -f "$full" ]; then
                    wallpaper_path="$full"
                    break
                fi
            fi
        done
    fi

    if [ -f "$wallpaper_path" ]; then
        echo "$wallpaper_path" > "$LAST_WALLPAPER_FILE"
        add_to_history "$selected"
        extension="${selected##*.}"

        killall gslapper 2>/dev/null

        if [ "${extension,,}" = "mp4" ]; then
            filename=$(basename "$selected")
            thumbnail_path="$THUMBNAIL_DIR/${filename%.*}.jpg"
            cp "$thumbnail_path" "$HOME/.cache/last_wallpaper_static.jpg"
            generate_wallpaper_theme "$thumbnail_path"
            gslapper -o "loop full" "*" "$wallpaper_path" & # animated wallpaper
        else
            magick "$wallpaper_path[0]" +adjoin "$HOME/.cache/last_wallpaper_static.jpg"
            generate_wallpaper_theme "$wallpaper_path"
        fi

        notify-send -a "Wallpaper" "  Wallpaper & Theme Applied" "$(basename "$selected")" -i "$wallpaper_path"

        # Generate square thumbnail for widgets
        magick "$HOME/.cache/last_wallpaper_static.jpg" \
            -gravity center \
            -extent "%[fx:min(w,h)]x%[fx:min(w,h)]" \
            "$HOME/.cache/last_wallpaper_static_square.jpg"

        # Signal waybar to refresh wallpaper module
        pkill -SIGRTMIN+9 waybar 2>/dev/null
    else
        notify-send -a "Wallpaper" "  Error" "Wallpaper file not found: $selected"
    fi
fi