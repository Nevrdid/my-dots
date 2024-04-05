source ~/.config/fish/nnn.fish
source /usr/share/doc/find-the-command/ftc.fish
source /opt/asdf-vm/asdf.fish

function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    set fish_greeting
end
set -g fish_key_bindings fish_vi_key_bindings

eval (luarocks path)
eval (batpipe)


starship init fish | source

set -x LD_LIBRARY_PATH /usr/local/lib/
set -x LUA_CPATH "/usr/lib/lua/5.4/?.so;$LUA_CPATH"

set -x EDITOR nvim
set -x SHELL fish
set -x BATPIPE color
set -x MANROFFOPT -c
set -x MANPAGER "sh -c 'col -bx | bat -plman'"

alias bathelp='bat --plain --language=help'
function help
    "$argv" --help 2>&1 | bathelp
end

alias Nvim "NVIM_APPNAME=Nvim nvim" # NormalNvim
alias Lvim "NVIM_APPNAME=Lvim nvim" # LazyNvim
alias Cvim "NVIM_APPNAME=Cvim nvim" # NvChad
alias Avim "NVIM_APPNAME=Avim nvim" # AstroNvim
alias Svim "NVIM_APPNAME=Svim nvim" # SpaceNvim

alias neorg 'nvim -c "Neorg index"'

alias pamcan pacman

alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
# bigest packages:
alias big="expac -H M '%m\t%n' | sort -h | nl"
# recently installed :
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias rofi="wofi"

alias mt-disk "udisksctl mount -b /dev/disk/by-id/usb-Generic_Mass-Storage_20181212000002-0:0-part1"
alias umt-disk "udisksctl unmount -b /dev/disk/by-id/usb-Generic_Mass-Storage_20181212000002-0:0-part1"
alias mt-datas "udisksctl mount -b /dev/disk/by-uuid/6ebb0885-18fa-42d6-a957-592034d07886"
alias umt-datas "udisksctl unmount -b /dev/disk/by-uuid/6ebb0885-18fa-42d6-a957-592034d07886"

function conserv --description "Toggle battery conservation_mode" --argument-name state
    if test "$state" = on
        sudo fish -c "echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
    else if test "$argv" = off
        sudo fish -c "echo 0 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
    end
end
