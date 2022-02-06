-- @feature disables the containers from krastorio 2

-- settings.lua
if mods["aai-containers"] and mods["Krastorio2"] then
    boolean("kr-containers", false)
end
