#!/usr/bin/env ruby

require 'optparse'

HELP = <<ENDHELP
variables - script for setting environment variables

Usage:
variables <operation> <options>...<options>

Operations:
-h --help             print help
-s --set              set variable
-c --choose           launch rofi and set variable

Options:
-f --file-path        path to file where variable stored
-n --name             name of the variable
-v --value            value of the variable (single string or multiple values separated by "|")
ENDHELP

def quote(str)
    "\"" + str + "\""
end

def replace_text_in_file(path, oldText, newText)
    puts "#{path}: '#{oldText}' replaced with '#{newText}'"
    `sed -i 's/#{oldText}/#{newText}/g' "#{path}"`
end

def check_arguments(path, name, value)
    if path.empty? || name.empty? || value.empty?
        puts "Error: Options is not specified correctly"
        exit
    end
end

def set_variable(path, name, value)
    currentValue = `grep "^#{name}=" "#{path}" | cut -d= -f2 | cut -d\\" -f2`.strip

    puts "currentValue=#{currentValue}"

    if currentValue.empty?
        `echo "#{name}=#{quote(value)}" >> #{path}`
    else
        replace_text_in_file(path, "#{name}=#{quote(currentValue)}", "#{name}=#{quote(value)}")
    end
end

def choose_variable(path, name, values)
    currentValue = `grep "^#{name}=" "#{path}" | cut -d= -f2 | cut -d\\" -f2`.strip

    options = values.join("|")
    selected = `echo "#{options}" | rofi -sep '|' -dmenu -p "Set value for #{name} (current is #{currentValue})" | xargs -r echo`.strip

    if selected.empty? == false
        set_variable(path, name, selected)
    end
end

def main()
    options = {}
    OptionParser.new do |opt|
        opt.on("-h", "--help") { |value| options[:help] = value }
        opt.on("-s", "--set") { |value| options[:set] = value }
        opt.on("-c", "--choose") { |value| options[:choose] = value }
        opt.on("-f FILEPATH", "--file-path FILEPATH") { |value| options[:path] = value }
        opt.on("-n NAME", "--name NAME") { |value| options[:name] = value }
        opt.on("-v VALUE", "--value NAME") { |value| options[:value] = value }
    end.parse!

    if options[:help] != nil || options.empty?
        puts HELP
        exit
    end

    path = options[:path] != nil ? options[:path] : ""
    name = options[:name] != nil ? options[:name] : ""
    value = options[:value] != nil ? options[:value] : ""

    check_arguments(path, name, value)

    if options[:set]
        set_variable(path, name, value)
    elsif options[:choose]
        values = value.split("|")
        choose_variable(path, name, values)
    end
end

main()