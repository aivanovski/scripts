#!/usr/bin/env ruby

# Launch Rofi with selection of config files to edit

EDITOR = 'nvim'.freeze

options = [
  '~/.bashrc',
  '~/.vimrc',
  '~/.config/i3/config',
  '~/.config/polybar/config.ini',
  '~/.config/nvim'
]

option = `echo "#{options.join('|')}" | rofi -sep '|' -dmenu -i | xargs -r echo`.strip

if !option.empty?
  path = option.gsub('~', '$HOME')
  `terminator  --command '#{EDITOR} #{path}'`
end
