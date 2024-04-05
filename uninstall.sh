#!/usr/bin/env bash
cd "$(dirname "$0")"
source ./scriptdata/ansi

function v() {
  echo "[$0]: ${green}Now executing:${reset}"
  echo "${green}" "$@" "${reset}"
  "$@"
}

echo 'Hi there!'
echo 'This script 1. will uninstall [end-4/dots-hyprland > illogical-impulse] dotfiles'
echo '            2. will try to revert *mostly everything* installed using install.sh, so it'\''s pretty destructive'
echo '            3. has not beed tested, use at your own risk.'
echo '            4. will show all commands that it runs.'
echo 'Ctrl+C to exit. Enter to continue.'
read -r
set -e
##############################################################################################################################

# Undo Step 3: Removing copied config and local folders
echo "${cyan}Removing copied config and local folders...${reset}"

for i in ags fish fontconfig foot fuzzel hypr mpv wlogout "starship.toml" rubyshot
  do v rm -rf "$HOME/.config/$i"
done

v rm -rf "$HOME/.local/bin/fuzzel-emoji"

##############################################################################################################################

# Undo Step 2: Uninstall AGS - Disabled for now, check issues
# echo 'Uninstalling AGS...'
# sudo meson uninstall -C ~/ags/build
# rm -rf ~/ags

##############################################################################################################################

# Undo Step 1: Remove added user from video and input groups and remove yay packages
echo "${cyan}Removing user from video and input groups and removing packages...${reset}"
user=$(whoami)
v sudo deluser "$user" video
v sudo deluser "$user" input

##############################################################################################################################
read -rp "Do you want to uninstall packages used by the dotfiles?\nCtrl+C to exit, or press Enter to proceed"

# Removing installed yay packages and dependencies
v yay -Rns adw-gtk3-git brightnessctl cava foot fuzzel gjs gojq gradience-git grim gtk-layer-shell hyprland-git lexend-fonts-git libdbusmenu-gtk3 plasma-browser-integration playerctl python-build python-material-color-utilities python-poetry python-pywal ripgrep sassc swww slurp starship swayidle hyprlock-git tesseract ttf-jetbrains-mono-nerd ttf-material-symbols-variable-git ttf-space-mono-nerd typescript webp-pixbuf-loader wl-clipboard wlogout yad ydotool

echo "${cyan}Uninstall Complete.${reset}"
