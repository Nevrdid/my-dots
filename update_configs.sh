#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	source ./scriptdata/ansi
	source ./scriptdata/functions
	source ./scriptdata/options
fi

#####################################################################################
echo "${cyan}[$0]: 3. Copying${reset}"

# In case some folders does not exists
v mkdir -p "$HOME"/.{config,cache,local/{bin,share}}

# `--delete' for rsync to make sure that
# original dotfiles and new ones in the SAME DIRECTORY
# (eg. in ~/.config/hypr) won't be mixed together
conf_sync() {
  folder=".config/$1"
	echo "[$0]: Found target: $folder"
	if [ -d "$folder" ]; then
		v rsync -av --delete "$1/" "$HOME/$folder/"
	elif [ -f "$folder" ]; then
		v rsync -av "$folder" "$HOME/$folder"
	fi
}
export -f conf_sync

# MISC (For .config/* but not AGS, not Fish, not Hyprland)
if ! $SKIP_MISCCONF; then
	find .config/ -mindepth 1 -maxdepth 1 ! -name 'ags' ! -name 'fish' ! -name 'hypr' -exec sh -c 'conf_sync "$@"' sh {} +
fi

if ! $SKIP_FISH; then
	v rsync -av --delete .config/fish/ "$HOME"/.config/fish/
fi

# For AGS
if ! $SKIP_AGS; then
	v rsync -av --delete --exclude '/user_options.js' .config/ags/ "$HOME"/.config/ags/
	t="$HOME/.config/ags/user_options.js"
	if [ -f "$t" ]; then
		echo "${blue}[$0]: \"$t\" already exists.${reset}"
		# v cp -f .config/ags/user_options.js $t.new
		existed_ags_opt=true
	else
		echo "${yellow}[$0]: \"$t\" does not exist yet.${reset}"
		v cp .config/ags/user_options.js "$t"
		existed_ags_opt=false
	fi
fi

# For Hyprland
if ! $SKIP_HYPRLAND; then
	v rsync -av --delete --exclude '/custom' --exclude '/hyprland.conf' .config/hypr/ "$HOME"/.config/hypr/
	t="$HOME/.config/hypr/hyprland.conf"
	if [ -f "$t" ]; then
		echo "${blue}[$0]: \"$t\" already exists.${reset}"
		v cp -f .config/hypr/hyprland.conf "$t".new
		existed_hypr_conf=true
	else
		echo "${yellow}[$0]: \"$t\" does not exist yet.${reset}"
		v cp .config/hypr/hyprland.conf "$t"
		existed_hypr_conf=false
	fi
	t="$HOME/.config/hypr/custom"
	if [ -d "$t" ]; then
		echo "${blue}[$0]: \"$t\" already exists, will not do anything.${reset}"
	else
		echo "${yellow}[$0]: \"$t\" does not exist yet.${reset}"
		v rsync -av --delete .config/hypr/custom/ "$t"/
	fi
fi

# some foldes (eg. .local/bin) should be processed separately to avoid `--delete' for rsync,
# since the files here come from different places, not only about one program.
v rsync -av ".local/bin/" "$HOME/.local/bin/"

# Prevent hyprland from not fully loaded
sleep 1
try hyprctl reload

#existed_zsh_conf=n
#grep -q 'source ~/.config/zshrc.d/dots-hyprland.zsh' ~/.zshrc && existed_zsh_conf=y

#####################################################################################
echo "${cyan}[$0]: Finished. See the \"Import Manually\" folder and grab anything you need.${reset}"
echo ""
echo "${cyan}If you are new to Hyprland, please read"
echo "https://end-4.github.io/dots-hyprland-wiki/en/i-i/01setup/#post-installation"
echo "for hints on launching Hyprland.${reset}"
echo ""
echo "${cyan}If you are already running Hyprland,${reset}"
echo "${cyan}Press ${black}${bg_cyan} Ctrl+Super+T ${reset}${cyan} to select a wallpaper${reset}"
echo "${cyan}Press ${black}${bg_cyan} Super+/ ${reset}${cyan} for a list of keybinds${reset}"
echo ""

if $existed_ags_opt; then
	echo ""
	echo "${yellow}[$0]: Warning: \"~/.config/ags/user_options.js\" already existed before and we didn't overwrite it. ${reset}"
	#    echo "${yellow}Please use \"~/.config/ags/user_options.js.new\" as a reference for a proper format.${reset}"
fi

if $existed_hypr_conf; then
	echo ""
	echo "${yellow}[$0]: Warning: \"~/.config/hypr/hyprland.conf\" already existed before and we didn't overwrite it. ${reset}"
	echo "${yellow}Please use \"~/.config/hypr/hyprland.conf.new\" as a reference for a proper format.${reset}"
	echo "${yellow}If this is your first time installation, you must overwrite \"~/.config/hypr/hyprland.conf\" with \"~/.config/hypr/hyprland.conf.new\".${reset}"
fi
