#!/usr/bin/env ruby

# Creates static links in ~/.local/bin for all executable files in current directory

SETUP_SCRIPT_NAME = 'setup.rb'.freeze

def file_exists(dir_path, file_name)
  `ls "#{dir_path}" --color=never | grep "^#{file_name}$"`.strip == file_name
end

def format_executable_name(name)
  dot_idx = name.rindex('.')

  if name.end_with? '.clj'
    name
  elsif dot_idx != nil
    name.slice(0..dot_idx - 1)
  else
    name
  end
end

def main
  current_path = `pwd`.strip
  launched_from_current_dir = file_exists(current_path, SETUP_SCRIPT_NAME)

  if launched_from_current_dir
    `ls -la #{current_path} --color=never | grep "^-..x.*\...$"`
      .strip
      .split("\n")
      .map { |line| line.split(' ')[8] }
      .filter { |name| name != SETUP_SCRIPT_NAME }
      .each { |name|
        executable_name = format_executable_name(name)

        src = "#{current_path}/#{name}"
        dst = "$HOME/.local/bin/#{executable_name}"

        success_message = "Successfully created link to: #{dst}"
        error_message = "Failed to create link to: #{src}"

        if file_exists('$HOME/.local/bin', executable_name)
          `rm "#{dst}"`
        end

        message = `ln -s "#{src}" "#{dst}" && echo "#{success_message}" || echo "#{error_message}"`.strip
        puts message.to_s
      }
  else
    puts 'Script should be launched from its located directory'
  end
end

main
