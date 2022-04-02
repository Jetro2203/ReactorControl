local name = "ReactorControl"
local version = "1.0.2"
 
local logFile = "OS/logs/Installer.log"
 
local files = {
    ["startup.lua"] = "0SBmYkMN",
    [name.."/System/Control.lua"] = "zUEdBysu",
    [name.."/System/Display.lua"] = "QFkTRvd1",
    [name.."/System/Redstone.lua"] = "8zfDPc3B",
    [name.."/System/Config.cfg"] = "qXFULTjg",
    [name.."/Symbols/Stop.nfp"] = "QJafZx6b",
    [name.."/Symbols/Start.nfp"] = "fmFckamj",
    [name.."/Symbols/Radioactive.nfp"] = "DXh3Pzzf",
    ["OS/APIs/screen.api"] = "uSzxUdLg",
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
    for location, pastebin_code in pairs(files) do
        if fs.exists(location) then
            log("deleting old file: "..location)
            fs.delete(location)
        end
    end
    log("\nComplete")
end

function new_download()
    log("Downloading new files...\n")
    for location, pastebin_code in pairs(files) do
        log("downloading new file: "..location)
        shell.run("pastebin","get",pastebin_code,location)
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
    shell.run("pastebin","get","M59hM8gQ",name.."/Installer.lua")
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
 