-- @feature force disables unfiltered miniloaders
-- @feature force enables filtered miniloaders
-- @feature force enables krastorio 2 loaders

-- settings.lua
if mods["miniloader"] and mods["Krastorio2"] then
    boolean("miniloader-enable-standard", false)
    boolean("miniloader-enable-filter", true)
    boolean("kr-loaders", true)
end
