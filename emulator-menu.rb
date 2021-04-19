#!/usr/bin/env ruby

# Launches Rofi menu with list of Android emulators
emulators = `emulator -list-avds`.split("\n").join("|")

id = `echo "#{emulators}" | rofi -sep '|' -dmenu -i | xargs -r echo`.strip

if id.empty? == false
    `export ANDROID_SDK_ROOT=$HOME/bin/android-sdk && emulator -avd "#{id}" &> /dev/null &`
end
