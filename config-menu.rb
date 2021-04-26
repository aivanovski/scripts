#!/usr/bin/env ruby

# Launch Rofi with selection of config files to edit

EDITOR = "code"

BASHRC = "~/.bashrc"
VIMRC = "~/.vimrc"
I3_CONFIG = "~/.config/i3/config"
POLYBAR_CONFIG = "~/.config/polybar/config.ini"

options = [
    BASHRC,
    VIMRC,
    I3_CONFIG,
    POLYBAR_CONFIG
]

option = `echo "#{options.join("|")}" | rofi -sep '|' -dmenu -i | xargs -r echo`.strip

if !option.empty?
    path = option.gsub("~", "$HOME")
    `exec #{EDITOR} "#{path}"`
end