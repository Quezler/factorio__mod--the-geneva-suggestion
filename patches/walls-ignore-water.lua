-- @feature prevents walls from graphically connecting to water or cliffs

-- data-updates.lua
for name, wall in pairs(data.raw["wall"]) do
    wall.pictures.water_connection_patch = nil
end
