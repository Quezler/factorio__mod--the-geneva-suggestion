-- @feature removes the filter slots from the krastorio 2 loaders
-- @feature removes the purple tint from filtered miniloaders

-- data.lua
if mods["miniloader"] and mods["Krastorio2"] then
    data.raw["loader-1x1"]["kr-loader"]         .filter_count = 0
    data.raw["loader-1x1"]["kr-fast-loader"]    .filter_count = 0
    data.raw["loader-1x1"]["kr-express-loader"] .filter_count = 0
    data.raw["loader-1x1"]["kr-advanced-loader"].filter_count = 0
    data.raw["loader-1x1"]["kr-superior-loader"].filter_count = 0

    require("prototypes.make-filtered-miniloaders-look-normal")
end

-- data-final-fixes.lua
if mods["miniloader"] and mods["Krastorio2"] and mods["space-exploration"] then
    data.raw["loader-1x1"]["kr-se-loader"]                 .filter_count = 0
    data.raw["loader-1x1"]["kr-se-deep-space-loader-black"].filter_count = 0
end
