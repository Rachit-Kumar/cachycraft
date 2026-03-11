#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║  cachycraft — Hyprland Rice Installer                ║
# ║  https://github.com/Rachit-Kumar/cachycraft          ║
# ╚══════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Colors ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
info() { echo -e "${CYAN}[→]${NC} $1"; }
ask()  { echo -ne "${BOLD}[?]${NC} $1 "; }

REPO="https://github.com/Rachit-Kumar/cachycraft.git"
DOTFILES="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# ─── Banner ───
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  🍚 ${BOLD}cachycraft${NC} — Hyprland Rice Installer         ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     CachyOS / Arch Linux                         ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Check OS ───
if ! grep -qi "arch\|cachyos" /etc/os-release 2>/dev/null; then
    err "This installer is designed for Arch Linux / CachyOS."
    err "Your OS may not be compatible. Proceed at your own risk."
    ask "Continue anyway? [y/N]"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]] || exit 1
fi

# ─── Check if running as root ───
if [ "$EUID" -eq 0 ]; then
    err "Do not run this script as root. Run as your normal user."
    exit 1
fi

# ─── Confirmation ───
echo -e "${YELLOW}⚠ WARNING: This will:${NC}"
echo "  • Install required packages via pacman and yay"
echo "  • Backup your current ~/.config to $BACKUP_DIR"
echo "  • Clone cachycraft dotfiles to $DOTFILES"
echo "  • Create symlinks via GNU Stow"
echo ""
ask "Proceed with installation? [y/N]"
read -r confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
echo ""

# ═══════════════════════════════════════
# 1. Install Dependencies
# ═══════════════════════════════════════
info "Installing dependencies..."

# Core Pacman packages
PACMAN_PKGS=(
    # Window Manager & Display
    hyprland hyprlock hypridle hyprshot
    # Bar & UI
    waybar rofi-wayland swaync wlogout swayosd
    # Wallpaper & Theming
    swww matugen imagemagick
    # Terminals & Shell
    kitty fish
    # Tools
    stow eza bat cliphist playerctl grim slurp
    # Fonts
    ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd
    # GTK Theme
    adw-gtk-theme
)

# Check which packages are missing
missing_pkgs=()
for pkg in "${PACMAN_PKGS[@]}"; do
    # Handle rofi-wayland fallback
    if [ "$pkg" == "rofi-wayland" ]; then
        if ! pacman -Si rofi-wayland &>/dev/null; then
            pkg="rofi"
        fi
    fi
    if ! pacman -Qi "$pkg" &>/dev/null; then
        missing_pkgs+=("$pkg")
    fi
done

if [ ${#missing_pkgs[@]} -gt 0 ]; then
    info "Installing ${#missing_pkgs[@]} packages via pacman..."
    sudo pacman -S --needed --noconfirm "${missing_pkgs[@]}" || {
        warn "Some pacman packages failed. You may need to install them manually."
    }
    log "Pacman packages installed"
else
    log "All pacman packages already installed"
fi

# AUR packages (requires yay or paru)
AUR_PKGS=(
    gruvbox-plus-icon-theme-git
    layan-cursor-theme-git
    snappy-switcher
)

if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
else
    warn "No AUR helper found (yay/paru). Skipping AUR packages."
    warn "You'll need to install manually: ${AUR_PKGS[*]}"
    AUR_HELPER=""
fi

if [ -n "$AUR_HELPER" ]; then
    missing_aur=()
    for pkg in "${AUR_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null 2>&1; then
            missing_aur+=("$pkg")
        fi
    done

    if [ ${#missing_aur[@]} -gt 0 ]; then
        info "Installing ${#missing_aur[@]} AUR packages via $AUR_HELPER..."
        $AUR_HELPER -S --needed --noconfirm "${missing_aur[@]}" || {
            warn "Some AUR packages failed. Install them manually."
        }
        log "AUR packages installed"
    else
        log "All AUR packages already installed"
    fi
fi

# ═══════════════════════════════════════
# 2. Set Fish as default shell
# ═══════════════════════════════════════
current_shell=$(basename "$SHELL")
if [ "$current_shell" != "fish" ]; then
    ask "Set Fish as your default shell? [Y/n]"
    read -r fish_confirm
    if [[ ! "$fish_confirm" =~ ^[Nn]$ ]]; then
        chsh -s /usr/bin/fish
        log "Default shell set to Fish"
    fi
else
    log "Fish is already default shell"
fi

# ═══════════════════════════════════════
# 3. Backup existing configs
# ═══════════════════════════════════════
info "Backing up existing configs..."

STOW_TARGETS=(
    ".config/hypr" ".config/waybar" ".config/rofi" ".config/fish"
    ".config/kitty" ".config/alacritty" ".config/swaync" ".config/wlogout"
    ".config/btop" ".config/fastfetch" ".config/swayosd" ".config/hyprlock"
    ".config/gtk-3.0" ".config/gtk-4.0" ".config/gtkrc" ".config/gtkrc-2.0"
    ".config/wallpaper-dirs" ".config/wallpaper-favorites"
    ".config/mimeapps.list" ".config/libinput-gestures.conf"
)

mkdir -p "$BACKUP_DIR"
backed_up=0
for target in "${STOW_TARGETS[@]}"; do
    src="$HOME/$target"
    if [ -e "$src" ] && [ ! -L "$src" ]; then
        dest="$BACKUP_DIR/$target"
        mkdir -p "$(dirname "$dest")"
        mv "$src" "$dest"
        backed_up=$((backed_up + 1))
    elif [ -L "$src" ]; then
        rm "$src"  # Remove old symlinks
    fi
done

if [ $backed_up -gt 0 ]; then
    log "Backed up $backed_up items to $BACKUP_DIR"
else
    log "No existing configs to backup"
fi

# ═══════════════════════════════════════
# 4. Clone dotfiles
# ═══════════════════════════════════════
if [ -d "$DOTFILES" ]; then
    warn "$DOTFILES already exists"
    ask "Remove and re-clone? [y/N]"
    read -r reclone
    if [[ "$reclone" =~ ^[Yy]$ ]]; then
        rm -rf "$DOTFILES"
    else
        info "Using existing $DOTFILES"
    fi
fi

if [ ! -d "$DOTFILES" ]; then
    info "Cloning cachycraft..."
    git clone "$REPO" "$DOTFILES"
    log "Cloned to $DOTFILES"
fi

# ═══════════════════════════════════════
# 5. Stow all packages
# ═══════════════════════════════════════
info "Creating symlinks with stow..."
cd "$DOTFILES"

stow_ok=0
stow_fail=0
for pkg in */; do
    pkg="${pkg%/}"
    [ "$pkg" = "scripts" ] && continue
    [ "$pkg" = ".git" ] && continue
    if stow "$pkg" 2>/dev/null; then
        log "Stowed $pkg"
        stow_ok=$((stow_ok + 1))
    else
        warn "Failed to stow $pkg (conflict?)"
        stow_fail=$((stow_fail + 1))
    fi
done

# ═══════════════════════════════════════
# 6. Post-install setup
# ═══════════════════════════════════════
info "Running post-install setup..."

# Initialize swww if not running
if ! pgrep -x swww-daemon &>/dev/null; then
    swww-daemon &
    sleep 0.5
fi

# Create required directories
mkdir -p "$HOME/Pictures/Wallpapers/All"
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Thumbnails"
mkdir -p "$HOME/.cache/wallpaper-thumbnails"

log "Directories created"

# ═══════════════════════════════════════
# 7. Done!
# ═══════════════════════════════════════
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}✨ cachycraft installed successfully!${NC}            ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Packages stowed:${NC} $stow_ok OK, $stow_fail failed"
echo -e "  ${BOLD}Backup location:${NC} $BACKUP_DIR"
echo ""
echo -e "  ${CYAN}Next steps:${NC}"
echo "  1. Log out and log back in (or reboot)"
echo "  2. Add wallpapers to ~/Pictures/Wallpapers/All/"
echo "  3. Press Super+W to pick a wallpaper"
echo "  4. Press Super+/ for keybinding cheatsheet"
echo ""
echo -e "  ${YELLOW}To revert:${NC}"
echo "  cd ~/.dotfiles && for pkg in */; do stow -D \"\${pkg%/}\"; done"
echo "  mv $BACKUP_DIR/* ~/.config/"
echo ""
echo -e "  🍚 ${BOLD}Enjoy your rice!${NC}"
echo ""
