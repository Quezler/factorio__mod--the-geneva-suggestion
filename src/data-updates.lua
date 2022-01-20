-- disable wall/cliff connecting for all walls
for name, wall in pairs(data.raw["wall"]) do
    wall.pictures.water_connection_patch = nil
end

-- undo the damage krastorio 2 does to aai containers
if mods["aai-containers"] and mods["Krastorio2"] then
    data.raw.item["wooden-chest"].subgroup = "container-1"
    data.raw.item["iron-chest"].subgroup = "container-1"
    data.raw.item["iron-chest"].order = "y[items]-a[wooden-chest]"
    data.raw.item["wooden-chest"].order = "z[items]-a[wooden-chest]"

    data.raw.item["logistic-chest-passive-provider"].order = "b[storage]-2-b[aai-strongbox-passive-provider]"
    data.raw.item["logistic-chest-active-provider"].order = "b[storage]-2-c[aai-strongbox-active-provider]"
    data.raw.item["logistic-chest-requester"].order = "b[storage]-2-f[aai-strongbox-requester]"
    data.raw.item["logistic-chest-storage"].order = "b[storage]-2-d[aai-strongbox-storage]"
    data.raw.item["logistic-chest-buffer"].order = "b[storage]-2-e[aai-strongbox-buffer]"
end
