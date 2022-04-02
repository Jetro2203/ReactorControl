local name = "ReactorControl"
local debug = true

local file = {
    reactorcontrol = {
        name.."/System/Control.lua",
        name.."/System/Display.lua",
        name.."/System/Redstone.lua",
    },
}

for i = 1, #file.reactorcontrol do
    if i ~= 1 then
        multishell.launch({},file.reactorcontrol[i])
    end
end
if debug then
    shell.run("fg")
    multishell.setTitle(4,"Debug")
end
multishell.setFocus(1)
shell.run(file.reactorcontrol[1])