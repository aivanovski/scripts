#!/usr/bin/env ruby

# emulators = `emulator -list-avds`.split("\n").join("|")
# `echo "#{emulators}" | rofi -sep '|' -dmenu | xargs -r emulator -avd`

require 'optparse'

UNSET = -1

DPI_LOW = 1
DPI_HIGH = 2

MONITOR_BUILT_IN = 1
MONITOR_EXTERNAL_OR_BUIT_IN = 2
MONITOR_EXTERNAL = 3

PATH_MONITOR_ENVIRONMENT = ".config/monitor-environment"

VARIABLE_MONITOR = "MON_ENV"
VARIABLE_DPI = "MON_DPI"

HELP = <<ENDHELP
monitor-setup - script to control monitors output

Arguments for common usage:
-h --help             print help
-m --monitor-env      launch rofi to set value for #{VARIABLE_MONITOR} variable at ~/#{PATH_MONITOR_ENVIRONMENT}
-d --dpi-env          launch rofi to set value for #{VARIABLE_DPI} variable at ~/#{PATH_MONITOR_ENVIRONMENT}
-e --external         switch output to external monitor (without modifiying environment)
-b --built-in         switch output to built-in monitor (without modifiying environment)
-s --setup-env        setup environment according to variables (e.g. configs)
ENDHELP

def replaceTextInFile(oldText, newText, filePath)
    puts "#{filePath}: '#{oldText}' replaced with '#{newText}'"
    `sed -i "s/#{oldText}/#{newText}/g" "#{filePath}"`
end

def replaceTextInFileAtLine(oldText, newText, filePath, lineNumber)
    puts "#{filePath}: '#{oldText}' replaced with '#{newText}' at line #{lineNumber}"
    `sed -i "#{lineNumber} s/#{oldText}/#{newText}/g" "#{filePath}"`
end

def setupXprofileVariable(variableName, expectedValue)
    filePath = `echo $HOME/.config/xprofile-variables`.strip
    currentValue = `grep "#{variableName}" "#{filePath}" | cut -d= -f2`.strip

    if currentValue != expectedValue
        replaceTextInFile("#{variableName}=#{currentValue}", "#{variableName}=#{expectedValue}", filePath)
    end
end

def setupVariableInI3Config(variableName, expectedValue)
    filePath = `echo $HOME/.config/i3/config`.strip
    currentValue = `grep "#{variableName}" "#{filePath}" | cut -d" " -f3`.strip
    
    if currentValue != expectedValue
        replaceTextInFile("#{variableName} #{currentValue}", "#{variableName} #{expectedValue}", filePath)
    end
end

def setupFontInPolybar(variableName, expectedValue, numberOfOccurence)
    filePath = `echo $HOME/.config/polybar/config.ini`.strip
    lineNumber = `grep -n "#{variableName}=" "#{filePath}" | cut -d: -f1`.strip.split("\n")[numberOfOccurence - 1]
    currentValue = `grep -n "#{variableName}=" "#{filePath}" | grep "^#{lineNumber}:" | cut -d= -f3 | cut -d\\; -f1`.strip

    if currentValue != expectedValue
        replaceTextInFileAtLine("#{variableName}=#{currentValue}", "#{variableName}=#{expectedValue}", filePath, lineNumber)
    end
end

def setupVariableInPolybar(variableName, expectedValue, numberOfOccurence)
    filePath = `echo $HOME/.config/polybar/config.ini`.strip
    lineNumber = `grep -n "#{variableName} = " "#{filePath}" | cut -d: -f1`.strip.split("\n")[numberOfOccurence - 1]
    currentValue = `grep -n "#{variableName} = " "#{filePath}" | grep "^#{lineNumber}:" | cut -d= -f2`.strip

    if currentValue != expectedValue
        replaceTextInFileAtLine("#{variableName} = #{currentValue}", "#{variableName} = #{expectedValue}", filePath, lineNumber)
    end
end

def setup_variable_in_firefox_config(variableName, expectedValue)
    configDirName = `ls $HOME/.mozilla/firefox | grep default`
        .strip
        .split("\n")
        .first()

    if !configDirName.empty?
        filePath = `echo $HOME/.mozilla/firefox/#{configDirName}/prefs.js`.strip
        lineNumber = `grep -n "#{variableName}" "#{filePath}" | cut -d: -f1`.strip
        currentValue = `grep "#{variableName}" "#{filePath}" | cut -d"," -f2 | cut -d\\" -f2`.strip

        if currentValue != expectedValue && !lineNumber.empty?
            replaceTextInFileAtLine("#{currentValue}", "#{expectedValue}", filePath, lineNumber)
        end
    end
end

def getMonitorIds()
    ids = `xrandr | grep " connected "`.strip.split("\n").map { |s| s.split(" ")[0]}
    # puts "monitorIds=#{ids}"
    ids
end

def getPrimaryMonitorId()
    ids = getMonitorIds()
    if ids.size == 1
        ids[0]
    else
        ids.detect { |id| isMonitorExternal(id) == false }
    end
end

def getExternalMonitorId()
    ids = getMonitorIds()
    ids.detect { |id| isMonitorExternal(id) }
end

def determineMonitorDensity(monitorId)
    if isMonitorExternal(monitorId)
        DPI_LOW
    else
        resolutionOut = `xrandr | grep "#{monitorId} connected" -A 1`.strip.split("\n")[1]
        resolutions = resolutionOut.split(" ")[0].split("x")
        monitorWidth = Integer(resolutions[0])
        monitorHeight = Integer(resolutions[1])
        if monitorWidth > 2000
            DPI_HIGH
        else
            DPI_LOW
        end
    end
end

def determineMonitorEnvironment()
    ids = getMonitorIds()
    if ids.size == 1
        MONITOR_BUILT_IN
    else
        MONITOR_EXTERNAL_OR_BUIT_IN
    end
end

def isMonitorExternal(monitorId)
    monitorId.include? "HDMI"
end

def setupEnvironmentDependsOnDpi(dpi)
    case dpi
    when DPI_LOW
        puts "Setting up for Low DPI..."

        setupXprofileVariable("GDK_SCALE", "1")
        setupXprofileVariable("GDK_DPI_SCALE", "1.1")
        setupXprofileVariable("QT_FONT_DPI", "96")

        setupVariableInI3Config("font pango:monospace", "12")

        setupFontInPolybar("Fantasque Sans Mono\:pixelsize", "14", 1)
        setupFontInPolybar("Material Icons\:size", "16", 1)
        setupVariableInPolybar("height", "22", 1)

        setup_variable_in_firefox_config("layout.css.devPixelsPerPx", "1")
    when DPI_HIGH
        puts "Setting up for High DPI..."

        setupXprofileVariable("GDK_SCALE", "2")
        setupXprofileVariable("GDK_DPI_SCALE", "0.9")
        setupXprofileVariable("QT_FONT_DPI", "192")

        setupVariableInI3Config("font pango:monospace", "20")

        setupFontInPolybar("Fantasque Sans Mono\:pixelsize", "20", 1)
        setupFontInPolybar("Material Icons\:size", "24", 1)
        setupVariableInPolybar("height", "40", 1)

        setup_variable_in_firefox_config("layout.css.devPixelsPerPx", "2")
    end
end

def readMonitorEnvironmentVariable()
    filePath = `echo $HOME/#{PATH_MONITOR_ENVIRONMENT}`.strip
    value = `grep "^#{VARIABLE_MONITOR}=" "#{filePath}" | cut -d= -f2 | cut -d\\" -f2`.strip
    case value
    when "BUILT_IN"
        MONITOR_BUILT_IN
    when "EXTERNAL_OR_BUILT_IN"
        MONITOR_EXTERNAL_OR_BUIT_IN
    else
        puts "Error: Incorrent value for #{VARIABLE_MONITOR} at ~/#{PATH_MONITOR_ENVIRONMENT}"
        UNSET
    end
end

def readMonitorDpiVariable()
    filePath = `echo $HOME/#{PATH_MONITOR_ENVIRONMENT}`.strip
    value = `grep "^#{VARIABLE_DPI}=" "#{filePath}" | cut -d= -f2 | cut -d\\" -f2`.strip
    case value
    when "HIGH"
        DPI_HIGH
    when "LOW"
        DPI_LOW
    else
        UNSET
    end
end

def setupMonitor(monitor)
    monitorIds = getMonitorIds()

    case monitor
    when MONITOR_BUILT_IN
        if monitorIds.size > 1
            puts "Enable #{getPrimaryMonitorId()}, disable #{getExternalMonitorId()}"
            `xrandr --output #{getPrimaryMonitorId()} --primary --auto --output #{getExternalMonitorId()} --off`
        else
            puts "Enable #{getPrimaryMonitorId()}"
            `xrandr --output #{getPrimaryMonitorId()} --primary --auto`
        end
    when MONITOR_EXTERNAL_OR_BUIT_IN
        if monitorIds.size > 1
            puts "Enable #{getExternalMonitorId()}, disable #{getPrimaryMonitorId()}"
            `xrandr --output #{getExternalMonitorId()} --primary --auto --output #{getPrimaryMonitorId()} --off`
        else
            puts "Enable #{getPrimaryMonitorId()}"
            `xrandr --output #{getPrimaryMonitorId()} --primary --auto`
        end
    when MONITOR_EXTERNAL
        if monitorIds.size > 1
            puts "Enable #{getExternalMonitorId()}, disable #{getPrimaryMonitorId()}"
            `xrandr --output #{getExternalMonitorId()} --primary --auto --output #{getPrimaryMonitorId()} --off`
        else
            puts "Enable #{getPrimaryMonitorId()}"
            `xrandr --output #{getPrimaryMonitorId()} --primary --auto`
        end
    end
end

def setupEnvitonment()
    monitorEnv = readMonitorEnvironmentVariable()
    dpiEnv = readMonitorDpiVariable()

    if monitorEnv == UNSET
        monitorEnv = determineMonitorEnvironment()
    end

    monitorId = monitorEnv == MONITOR_BUILT_IN ? getPrimaryMonitorId() : getExternalMonitorId()
    if monitorId == nil
        monitorId = getPrimaryMonitorId()
    end

    if dpiEnv == UNSET
        dpiEnv = determineMonitorDensity(monitorId)
    end

    setupEnvironmentDependsOnDpi(dpiEnv)
    setupMonitor(monitorEnv)
end

def main()
    options = {}
    OptionParser.new do |opt|
        opt.on("-h", "--help") { |value| options[:help] = value }
        opt.on("-m", "--monitor-env") { |value| options[:monitor_env] = value }
        opt.on("-d", "--dpi-env") { |value| options[:dpi_env] = value }

        opt.on("-e", "--external") { |value| options[:external] = value }
        opt.on("-b", "--built-in") { |value| options[:built_in] = value }
        opt.on("-s", "--setup") { |value| options[:setup] = value }
    end.parse!

    if options[:help] != nil || options.empty?
        puts HELP
        exit
    end

    if options[:monitor_env]
        values = ["BUILT_IN", "EXTERNAL_OR_BUILT_IN"].join("|")
        `variables --choose --file-path ~/#{PATH_MONITOR_ENVIRONMENT} --name #{VARIABLE_MONITOR} --value "#{values}"`
    elsif options[:dpi_env]
        values = ["LOW", "HIGH", "UNSET"].join("|")
        `variables --choose --file-path ~/#{PATH_MONITOR_ENVIRONMENT} --name #{VARIABLE_DPI} --value "#{values}"`
    elsif options[:external]
        setupMonitor(MONITOR_EXTERNAL)
    elsif options[:built_in]
        setupMonitor(MONITOR_BUILT_IN)
    elsif options[:setup]
        setupEnvitonment()
    end
end

main()