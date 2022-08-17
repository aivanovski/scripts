#!/usr/bin/env ruby

# Show list of processes with FZF and kills selected

platform = `uname | head -1`.strip

case platform
when 'Darwin'
  pid = `ps -u "$(id -u)" -o pid,time,command | fzf -m | awk '{print $1}'`.strip
when 'Linux'
  pid = `ps --user "$(id -u)" -o pid,time,cmd | fzf -m | awk '{print $1}'`.strip
else
  puts 'Unsupported Operation System'
  exit 1
end

if !pid.empty? && pid != 'PID'
  `kill -9 #{pid}`
  puts "Killing process with pid=#{pid}"
end
