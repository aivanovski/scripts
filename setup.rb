#!/usr/bin/env ruby

# Creates static links in ~/.local/bin for all executable files in current directory

SETUP_SCRIPT_NAME = "setup.rb"

def is_file_exists(dirPath, fileName)
    `ls "#{dirPath}" --color=never | grep "^#{fileName}$"`.strip == fileName
end

def remove_file_extension_from_name(name)
    dotIdx = name.rindex('.')

    if dotIdx != nil
        name.slice(0..dotIdx - 1)
    else
        name
    end
end

def main()
    currentPath = `pwd`.strip
    isLaunchedFromCurrentDir = is_file_exists(currentPath, SETUP_SCRIPT_NAME)

    if isLaunchedFromCurrentDir
        `ls -la #{currentPath} --color=never | grep "^-..x.*\.rb$"`
            .strip
            .split("\n")
            .map { |line| 
                line.split(" ")[8]
            }
            .filter { |name| name != SETUP_SCRIPT_NAME }
            .each { |name|
                executableName = remove_file_extension_from_name(name)

                src = "#{currentPath}/#{name}"
                dst = "$HOME/.local/bin/#{executableName}"

                successMessage = "Successfully created link to: #{dst}"
                errorMessage = "Failed to create link to: #{src}"

                isLinkExists = is_file_exists("$HOME/.local/bin", executableName)

                if isLinkExists
                    `rm "#{dst}"`
                end

                message = `ln -s "#{src}" "#{dst}" && echo "#{successMessage}" || echo "#{errorMessage}"`.strip
                puts "#{message}"
            }
    else
        puts "Script should be launched from its located directory"
    end
end

main()

