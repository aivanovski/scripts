#!/usr/bin/env ruby

# Search for process to kill with Rofi

data = `ps --user "$(id -u)" -o pid,time,cmd | rofi -dmenu -i | xargs -r echo`.strip.split(" ")

if data.size >= 3 && data[0] != "PID"
    pid = data[0]

    `kill -9 "#{pid}"`
    puts "Killing process with pid=#{pid}"
end