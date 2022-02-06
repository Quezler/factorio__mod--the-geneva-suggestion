-- @feature allows placing rails on creep (including everything else using the ["floor-layer"](https://github.com/wube/factorio-data/blob/master/core/lualib/collision-mask-util.lua))

-- data.lua
if mods["Krastorio2"] then
    local util = require("util")
    util.remove_from_list(data.raw["tile"]["kr-creep"].collision_mask, "floor-layer")
end
