#!/usr/bin/env ruby

# Launches Rofi with menu: poweroff/suspend/reboot

actions = [
    # [Name, Command]
    ["Poweroff", "poweroff"],
    ["Suspend", "systemctl suspend"],
    ["Logout", "i3-msg exit"],
    ["Reboot", "reboot"]
]

names = actions.map { |a| a[0]}.join("|")
selectedName = `echo "#{names}" | rofi -sep '|' -dmenu -i | xargs -r echo`.strip

actions
    .filter { |a| a[0] == selectedName }
    .each { |a|
        command = a[1]
        `#{command}`
    }