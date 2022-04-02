--[[

    Name = Control.lua
    Version = 1.2.2
    Date = 1/4/2022
    Time = 18:16
    Author = Jetro

]]

-- Variables

local name = "ReactorControl"
local filename = name.."/System/Control.lua"
local version = "1.2.1"

local reactor = {}
local turbine = {}
local battery = {}
local mon = {}

local last = {
    page = {
        term,
        mon,
    },
    button = {
        automode,
    }
}

local file = {
    config = "ReactorControl/System/Config.cfg",
    log = "ReactorControl/System/log.log"
}

local tW, tH

-- Functions

function config_read()
    if fs.exists(file.config) then
        myConfig = fs.open(file.config,"r")
        config = textutils.unserialise(myConfig.readAll())
        myConfig.close()
    else
        log("error","unable to find configfile")
        error()
    end
end

function config_write()
    if config then
        table.sort(config)
        myConfig = fs.open(file.config,"w")
        myConfig.write(textutils.serialise(config))
        myConfig.close()
    else
        log("error","Config is nill")
        error()
    end
end

function log(logType, data)
    myLog = fs.open(file.log,"a")
    myLog.write("["..string.upper(logType).."] ["..filename.."] "..data.."\n")
    myLog.close()
    if string.lower(logType) == "error" then
        table.insert(config.error,"["..logType.."] ["..filename.."] "..data)
    elseif string.lower(logType) == "warning" then
        table.insert(config.warning,"["..logType.."] ["..filename.."] "..data)
    end
    config_write()
end

function init_peripheral()
    PList = peripheral.getNames()
    for i = 1, #PList do
        if peripheral.getType(PList[i]) == "BigReactors-Reactor" then
            table.insert(reactor,PList[i])
        elseif peripheral.getType(PList[i]) == "BigReactors-Turbine" then
            table.insert(turbine,PList[i])
        elseif peripheral.getType(PList[i]) == "capacitor_bank" then
            table.insert(battery,PList[i])
        elseif peripheral.getType(PList[i]) == "monitor" then
            table.insert(mon,PList[i])
        end
        table.sort(reactor)
        table.sort(turbine)
        table.sort(battery)
        table.sort(mon)
    end

    for i = 1, #reactor do
        reactor[i] = peripheral.wrap(reactor[i])
    end
    for i = 1, #turbine do
        turbine[i] = peripheral.wrap(turbine[i])
    end
    for i = 1, #battery do
        battery[i] = peripheral.wrap(battery[i])
    end
    for i = 1, #mon do
        mon[i] = peripheral.wrap(mon[i])
    end
end

function init_term()
    tW,tH = term.getSize()
    draw_menu_t()
end

function draw_menu_t()
    screen.clear(colors.blue,colors.black)
    screen.drawText(1,1,name.." v"..version)
    screen.drawText(tW-string.len(config.page.term),1,string.upper(config.page.term))
    if config.page.term == "home" then
        screen.drawText(1,3,"STATE:")
        screen.drawText(11,3,config.program_state,colors.blue,(string.lower(config.program_state) == "unknown" and colors.red) or colors.black)
        screen.drawText(1,5,"WARNINGS:",colors.blue,colors.black)
        screen.drawText(11,5,#config.warning,colors.blue,(#config.warning == 0 and colors.lime) or colors.red)
        screen.drawText(1,6,"ERRORS:",colors.blue,colors.black)
        screen.drawText(11,6,#config.error,colors.blue,(#config.error == 0 and colors.lime) or colors.red)
        screen.drawText(1,8,"CONTROLS",colors.blue,colors.black)
        screen.drawText(1,9,"S - edit settings")
        screen.drawText(1,10,"W - view warnings")
        screen.drawText(1,11,"E - view errors")
        screen.drawText(1,12,"C - commands")
        screen.drawText(1,13,"U - update")
    elseif config.page.term == "settings" then
        
    elseif config.page.term == "warnings" then
        
    elseif config.page.term == "errors" then
        
    elseif config.page.term == "commands" then

    elseif config.page.term == "update" then
        screen.drawText(1,3,"This will run the "..name.." installer",colors.blue,colors.black)
        screen.drawText(1,4,"Are you sure [Y/N]\n")
        event, key = os.pullEvent("key")
        if key == keys.y then
            shell.run("pastebin","run","M59hM8gQ")
        elseif key == keys.n then
            screen.drawText(1,6,"update cancelled")
            sleep(1)
            config.page.term = "home"
            config_write()
        end
    end
end

function reactor_start()
    for i = 1, #reactor do
        if config.reactor.lockout[i] then
            reactor[i].setActive(true)
        end
    end
end

function reactor_stop()
    for i = 1, #reactor do
        reactor[i].setActive(false)
    end
end

function turbine_start()
    for i = 1, #turbine do
        if config.turbine.lockout[i] then
            turbine[i].setActive(true)
        end
    end
end

function turbine_stop()
    for i = 1, #turbine do
        turbine[i].setActive(false)
        turbine[i].setInductorEngaged(false)
    end
end

function control_touch()
    event, a, b, c = os.pullEvent()
    config_read()
    if event == "monitor_touch" then
        side = a
        x = b
        y = c
        if x >= 1 and x <= 9 and y == 1 then
            config.page.mon = "home"
        elseif x >= 10 and x <= 19 and y == 1 then
            config.page.mon = "reactor"
        elseif x >= 20 and x <= 29 and y == 1 then
            config.page.mon = "turbine"
        elseif x >= 30 and x <= 39 and y == 1 then
            config.page.mon = "battery"
        end
        
        if last.page.mon ~= config.page.mon then
            config_write()
        end
        last.page.mon = config.page.mon

        if config.page.mon == "home" then
            if x >= 12 and x <= 15 and y == 3 then
                if config.button.automode then
                    reactor_stop()
                    turbine_stop()
                    config.button.automode = false
                elseif not(config.button.automode) then
                    config.button.automode = true
                end
            elseif x >= 95 and x <= 119 and y >= 4 and y <= 12 then
                reactor_start()
                turbine_start()
                config.button.automode = true
            elseif x >= 95 and x <= 119 and y >= 14 and y <= 22 then
                reactor_stop()
                turbine_stop()
                config.button.automode = false
            end

            if last.button.automode ~= config.button.automode then
                config_write()
            end
            last.button.automode = config.button.automode

        elseif config.page.mon == "reactor" then
        
        elseif config.page.mon == "turbine" then
        
        elseif config.page.mon == "battery" then

        end
    elseif event == "key" then
        key = a
        if key == keys.h then
            if config.page.term ~= "home" then
                config.page.term = "home"
            end
        elseif key == keys.s then
            if config.page.term == "settings" then
                config.page.term = "home"
            else
                config.page.term = "settings"
            end
        elseif key == keys.w then
            if config.page.term == "warnings" then
                config.page.term = "home"
            else
                config.page.term = "warnings"
            end
        elseif key == keys.e then
            if config.page.term == "errors" then
                config.page.term = "home"
            else
                config.page.term = "errors"
            end
        elseif key == keys.c then
            if config.page.term == "commands" then
                config.page.term = "home"
            else
                config.page.term = "commands"
            end
        elseif key == keys.u then
            sleep(.1)
            if config.page.term == "update" then
                config.page.term = "home"
            else
                config.page.term = "update"
            end
        end
        if last.page.term ~= config.page.term then
            config_write()
        end
        last.page.term = config.page.term
    end
end

function start()
    config_read()
    init_peripheral()
    init_term()
    main()
end

function main()
    while true do
        draw_menu_t()
        control_touch()
    end
end

-- Main

start()