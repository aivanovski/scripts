#!/usr/bin/env ruby

# Kills ADB processes

def parse_process_ids(output)
    if !output.empty?
        ids = output.split("\n")
            .map { |line| line.split(" ") }
            .filter { |items| items.size > 10 }
            .filter { |items| 
                processCommand = items[10]
                processCommand.include? 'adb'
            }
            .map { |items| items[1] }
        ids
    else
        []
    end
end

process_ids = parse_process_ids(`ps aux | grep adb`.strip)

if !process_ids.empty?
    puts "Killing ADB processes: #{process_ids.join(", ")}"
    process_ids.each { |id| `kill -15 #{id}` }
else
    puts "No ADB processes"
end
