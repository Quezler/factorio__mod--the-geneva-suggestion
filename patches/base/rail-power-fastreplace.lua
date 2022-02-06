-- @feature allows big electric poles and substations to fast-replace each other

-- data.lua

if mods["base"] then
  data.raw["electric-pole"]["big-electric-pole"].fast_replaceable_group = "rail-power"
  data.raw["electric-pole"]["substation"].fast_replaceable_group = "rail-power"
end
