#!/usr/bin/env ruby

# Show list of processes with FZF and kills selected

pid = `ps --user "$(id -u)" -o pid,time,cmd | fzf -m | awk '{print $1}'`.strip

if !pid.empty? && pid != 'PID'
  `kill -9 #{pid}`
  puts "Killing process with pid=#{pid}"
end
