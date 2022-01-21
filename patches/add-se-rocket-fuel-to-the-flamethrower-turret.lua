--[[
feature: allows for rocket fuel to be used in flamethrower turrets (115% damage)
]]--

-- data.lua
if mods["base"] and mods["space-exploration"] then
    table.insert(data.raw["fluid-turret"]["flamethrower-turret"].attack_parameters.fluids, {type = "se-liquid-rocket-fuel", damage_modifier = 1.15})
end
