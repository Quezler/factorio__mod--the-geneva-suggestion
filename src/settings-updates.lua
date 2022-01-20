local function boolean(key, value)
    data.raw["bool-setting"][key].hidden = true
    data.raw["bool-setting"][key].forced_value = value
end

if mods["aai-containers"] then
    boolean("aai-containers-number-icons", false)

    if mods["Krastorio2"] then
        boolean("kr-containers", false)
    end
end

if mods["miniloader"] then
    boolean("miniloader-enable-chute", false)
    boolean("miniloader-energy-usage", false)

    if mods["Krastorio2"] then
        boolean("miniloader-enable-standard", false)
        boolean("miniloader-enable-filter", true)
    end
end

if mods["Krastorio2"] then
    boolean("kr-finite-oil", false)
    boolean("kr-spidertron-exoskeleton", true)
    boolean("kr-main-menu-override-simulations", false)
end
