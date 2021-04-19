#!/usr/bin/env ruby

# Launches rofi menu with list of installed Android Studio's or launches it
# if there is only one installation on Android Studio

BASE_PATH = "$HOME/bin"

def find_android_studio_installations()
    data = `ls #{BASE_PATH} | cut -d" " -f1`
        .split("\n")
        .each { |name| name.strip }
        .filter { |name| name.start_with?("android-studio") }
        .map { |name|
            descriptorPath = "#{BASE_PATH}/#{name}/product-info.json"
            description = `cat #{descriptorPath}`
                .gsub("\"", "")
                .split("\n")
                .map { |line| line.strip }

            cleanName = description
                .filter { |line| line.start_with?("name:") }
                .map { |line| line.gsub(",", "").split(":")[1].strip }
                .first

            version = description
                .filter { |line| line.start_with?("version:") }
                .map { |line| line.gsub(",", "").split(":")[1].strip }
                .first

            build = description
                .filter { |line| line.start_with?("buildNumber:") }
                .map { |line| line.gsub(",", "").split(":")[1].strip }
                .first

            title = name
            if cleanName != nil
                title = cleanName

                if version != nil
                    title += " v#{version}"
                end

                if build != nil
                    title += ", build #{build}"
                end
            end

            ["#{BASE_PATH}/#{name}", title]
        }

    data
end

def create_dictionary_from_data(data)
    hash = {}

    data.each { |a|
        path = a[0]
        title = a[1]
        hash[title] = path
    }

    puts "size=#{data.size}"

    hash
end

def launch_rofi(data)
    entries = data.map { |a| a[1] }.join("|")
    selected = `echo "#{entries}" | rofi -sep '|' -dmenu -i | xargs -r echo`.strip
    selected
end

def main()
    data = find_android_studio_installations()
    if data.size == 1
        `#{data[0][0]}/bin/studio.sh &> /dev/null &`
    elsif data.size > 1
        dictionary = create_dictionary_from_data(data)
        selected = launch_rofi(data)

        if selected.empty? == false
            selectedPath = dictionary[selected]

            `#{selectedPath}/bin/studio.sh &> /dev/null &`
        end
    end
end

main()
