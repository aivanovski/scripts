#!/usr/bin/env ruby

# Kills Gradle daemons 

def parse_process_ids(output)
    if !output.empty?
        ids = output.split("\n")
            .map { |line| line.split(" ") }
            .filter { |items| items.size > 10 }
            .filter { |items| 
                processCommand = items[10]
                processCommand.include? "java"
            }
            .map { |items| items[1] }
        ids
    else
        []
    end
end

gradleDaemonIds = parse_process_ids(`ps aux | grep gradle | grep GradleDaemon`.strip)
kotlinCompileDaemonIds = parse_process_ids(`ps aux | grep gradle | grep KotlinCompileDaemon`.strip)

if gradleDaemonIds.size > 0
    puts "Killing Gradle Daemon: #{gradleDaemonIds.join(", ")}"
    gradleDaemonIds.each { |id| `kill -9 #{id}` }
else
    puts "No Gradle Daemon"
end

if kotlinCompileDaemonIds.size > 0
    puts "Killing Kotlin Daemon: #{kotlinCompileDaemonIds.join(", ")}"
    kotlinCompileDaemonIds.each { |id| `kill -9 #{id}` }
else
    puts "No Kotlin Daemon"
end