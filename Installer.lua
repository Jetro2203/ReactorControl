--[[

    Name = Installer.lua
    Version = 2.0
    Date = 2/4/2022
    Time = 18:41
    Author = Jetro

]]

-- Variables

local name = "ReactorControl"
local version = "2.0"

local logFile = "OS/logs/Installer.log"

local files = {
    ["startup.lua"] = "https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/startup.lua",
    [name.."/System/Control.lua"] = "https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/System/Control.lua",
    [name.."/System/Display.lua"] = "https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/System/Display.lua",
    [name.."/System/Redstone.lua"] = "https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/System/Redstone.lua",
    [name.."/System/Config.cfg"] = "https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/System/Config.cfg",
    [name.."/Symbols/Stop.nfp"] = "https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/Symbols/Stop.nfp",
    [name.."/Symbols/Start.nfp"] = "https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/Symbols/Start.nfp",
    [name.."/Symbols/RadioActive.nfp"] = "https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/Symbols/Radioactive.nfp",
    ["OS/APIs/screen.api"] = "https://raw.githubusercontent.com/Jetro2203/APIs/main/screen.api",
}

-- Functions

function log(data)
    myLog = fs.open(logFile,"a")
    print(data)
    myLog.write(data.."\n")
    myLog.close()
end

function old_delete()
    log("Deleting old files...\n")
    for location, github in pairs(files) do
        log("deleting old file: "..location)
        fs.delete(location)
    end
    log("\nComplete")
end

function new_download()
    log("Downloading new files...\n")
    for location, github in pairs(files) do
        log("downloading new file: "..location)
        shell.run("wget",github,location)
    end
    log("\nComplete")   
end

-- Main
 
shell.run("clear")
 
if fs.exists(logFile) then
    fs.delete(logFile)
end
myLog = fs.open(logFile,"w")
myLog.close()
 
log(name.." Installer\nVersion "..version.."\n")
 
log("[1] Update Installer")
log("[2] Install "..name)
input = read()
x,y = term.getCursorPos()
term.setCursorPos(x,y-1)
log(input)
if input == "1" then
    log("\nDeleting old installer...")
    fs.delete(name.."/Installer.lua")
    log("\nComplete")
    log("\nDownloading new installer")
    shell.run("wget","https://github.com/Jetro2203/ReactorControl/blob/main/Installer.lua",name.."/Installer.lua")
    log("\nComplete")
    log("started new installer...")
    sleep(1)
    shell.run(name.."/Installer.lua")
elseif input == "2" then
    if fs.exists(name.."/") then
        log("\nold version found")
        log("do you want to update? [Y/N]")
        input = string.upper(read())
        x,y = term.getCursorPos()
        term.setCursorPos(x,y-1)
        log(input)
        if input == "Y" then
            old_delete()
            new_download()
            log("\nLogFile: "..logFile)
            log("Rebooting...")
            sleep(2)
            os.reboot()
        elseif input == "N" then
            log("")
            log("Cancelling update")
            sleep(1)
            shell.run("clear")
        end
    else
        log("\nno old version found")
        log("do you want to install "..name.."? [Y/N]")
        input = string.upper(read())
        x,y = term.getCursorPos()
        term.setCursorPos(x,y-1)
        log(input)
        if input == "Y" then
            old_delete()
            new_download()
            log("\nLogFile: "..logFile)
            log("Rebooting...")
            sleep(2)
            os.reboot()
        elseif input == "N" then
            log("")
            log("Cancelling update")
            sleep(1)
            shell.run("clear")
        end
    end
end
 
