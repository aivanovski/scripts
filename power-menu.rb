#!/usr/bin/env ruby

# Launches Rofi with menu: poweroff/suspend/reboot

actions = [
    # [Name, Command]
    ['Poweroff', 'poweroff'],
    ['Suspend', 'systemctl suspend'],
    ['Logout', 'i3-msg exit'],
    ['Reboot', 'reboot']
]

names = actions.map { |a| a[0] }.join('|')
selected_name = `echo "#{names}" | rofi -sep '|' -dmenu -i | xargs -r echo`.strip

actions
  .filter { |action| action[0] == selected_name }
  .each { |command| `#{command[1]}` }
