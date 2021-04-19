#!/usr/bin/env ruby

# Launches Rofi with menu: poweroff/suspend/reboot

POWER_OFF = "poweroff"
SUSPEND = "suspend"
REBOOT = "reboot"

actions = [POWER_OFF, SUSPEND, REBOOT].join("|")

action = `echo "#{actions}" | rofi -sep '|' -dmenu -i | xargs -r echo`.strip

case action
when POWER_OFF
    `poweroff`
when SUSPEND
    `systemctl suspend`
when REBOOT
    `reboot`
end

