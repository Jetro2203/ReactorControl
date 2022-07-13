--[[

    Name = Installer.lua
    Version = 2.0
    Date = 6/4/2022
    Time = 15:15
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

function delete_file(location)
    log("Deleting files: "..location)
    fs.delete(location)
end

function delete_all(table_files)
    log("\nDeleting all files...")
    for location, URL in pairs(table_files) do
        delete_file(location)
    end
    log("\nComplete")
end

function write_file(location, data)
    if fs.exists(location) then
        log("Unable to create new file: file already exists: "..location)
        error("Unable to create new file: file already exists: "..location)
    else
        myFile = fs.open(location, "w")
        myFile.write(data)
        myFile.close()
    end
end

function download_file(URL,location)
    log("Downloading "..URL.." as "..location)
    if http.checkURL(URL) then
        myGithub = http.get(URL)
        data = myGithub.readAll()
        myGithub.close()
        write_file(location,data)
    else
        error("Unable to find URL:"..URL)
    end
end

function download_all(table_files)
    log("\nDownloading all files...")
    for location, URL in pairs(table_files) do
        download_file(URL,location)
    end
    log("\nComplete")
end

function update()
    delete_all(files)
    download_all(files)
    log("\nLogFile: "..logFile)
    log("Rebooting...")
    myStartup = fs.open("OS/files/StartupMode.txt","w")
    myStartup.write(name.."_normal")
    myStartup.close()
    sleep(2)
    os.reboot()
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
    shell.run("wget","https://raw.githubusercontent.com/Jetro2203/ReactorControl/main/Installer.lua",name.."/Installer.lua")
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
            update()
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
            update()
        elseif input == "N" then
            log("")
            log("Cancelling update")
            sleep(1)
            shell.run("clear")
        end
    end
end
 
