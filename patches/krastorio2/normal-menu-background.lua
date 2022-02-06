-- @feature prevents only the krastorio 2 background from showing in the main menu

-- settings.lua
if mods["Krastorio2"] then
    boolean("kr-main-menu-override-simulations", false)
end
