-- data-final-fixes.lua

if mods["space-exploration"] then
    local collision_mask_util = require("collision-mask-util")
    local asteroid_layer = collision_mask_util.get_first_unused_layer()

    table.insert(data.raw["item"]["se-space-platform-scaffold"].place_as_tile.condition, asteroid_layer)
    table.insert(data.raw["tile"]["se-asteroid"].collision_mask, asteroid_layer)
end
