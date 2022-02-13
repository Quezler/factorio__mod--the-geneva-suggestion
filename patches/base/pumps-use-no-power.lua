-- @feature pumps require no power

-- data-updates.lua
if mods["base"] then
  data.raw["pump"]["pump"].energy_source = {type = "void"}
end
