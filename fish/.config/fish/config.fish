source /usr/share/cachyos-fish-config/cachyos-config.fish

# ─── Environment ───
set -gx EDITOR nano
set -gx VISUAL nano
set -gx BROWSER brave

# ─── Path ───
fish_add_path /home/rachit/.opencode/bin

# ─── Abbreviations (expand on Tab/Enter, better than aliases) ───
# Git
abbr -a gs  'git status'
abbr -a ga  'git add'
abbr -a gaa 'git add --all'
abbr -a gc  'git commit'
abbr -a gcm 'git commit -m'
abbr -a gp  'git push'
abbr -a gl  'git pull'
abbr -a gd  'git diff'
abbr -a glog 'git log --oneline --graph --decorate -15'
abbr -a gb  'git branch'
abbr -a gco 'git checkout'
abbr -a gsw 'git switch'

# Files & navigation
abbr -a ll  'eza -la --icons --group-directories-first'
abbr -a la  'eza -a --icons --group-directories-first'
abbr -a lt  'eza --tree --level=2 --icons'
abbr -a cat 'bat --style=auto'

# System
abbr -a pacs  'pacman -Ss'   # search packages
abbr -a paci  'sudo pacman -S'  # install
abbr -a pacr  'sudo pacman -Rns' # remove with deps
abbr -a pacu  'sudo pacman -Syu' # full upgrade
abbr -a yays  'yay -Ss'     # search AUR
abbr -a yayi  'yay -S'      # install from AUR

# Hyprland shortcuts
abbr -a hrc  'nano ~/.config/hypr/configs/'
abbr -a reload 'hyprctl reload'

# Quick dirs
abbr -a dots 'cd ~/.config'
abbr -a dl   'cd ~/Downloads'
abbr -a pics 'cd ~/Pictures'

# ─── Custom greeting ───
function fish_greeting
    echo ""
    printf "  \033[1;36m%s\033[0m @ \033[1;35m%s\033[0m\n" (whoami) (hostname)
    printf "  \033[0;90m%s  •  %s  •  Uptime: %s\033[0m\n" (date "+%a %b %d, %H:%M") (uname -r | cut -d'-' -f1) (uptime -p | sed 's/up //')
    echo ""
end
