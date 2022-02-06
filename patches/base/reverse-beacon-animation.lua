-- @feature reverses the beacon animation to pulse into the ground

-- data.lua
if mods["base"] then
  data.raw["beacon"]["beacon"].graphics_set.animation_list[3].animation           .run_mode = "backward"
  data.raw["beacon"]["beacon"].graphics_set.animation_list[3].animation.hr_version.run_mode = "backward"
end
