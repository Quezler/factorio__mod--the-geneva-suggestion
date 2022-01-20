if mods["base"] and mods["space-exploration"] then
    table.insert(data.raw["fluid-turret"]["flamethrower-turret"].attack_parameters.fluids, {type = "se-liquid-rocket-fuel", damage_modifier = 1.15})
end

if mods["miniloader"] and mods["Krastorio2"] then
    data.raw["loader-1x1"]["kr-loader"]         .filter_count = 0
    data.raw["loader-1x1"]["kr-fast-loader"]    .filter_count = 0
    data.raw["loader-1x1"]["kr-express-loader"] .filter_count = 0
    data.raw["loader-1x1"]["kr-advanced-loader"].filter_count = 0
    data.raw["loader-1x1"]["kr-superior-loader"].filter_count = 0

    require("prototypes.make-filtered-miniloaders-look-normal")
end
