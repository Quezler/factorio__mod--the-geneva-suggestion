local construction_robot = require("construction-robot")

local kr_air_purifier = {}

function kr_air_purifier.init()
  global["kr-air-purifiers"] = {}
  global["pollution-filter-deliveries"] = {}

    for _, surface in pairs(game.surfaces) do
      for _, entity in pairs(surface.find_entities_filtered{name = "kr-air-purifier"}) do
        table.insert(global["kr-air-purifiers"], entity)
      end
    end
end

function kr_air_purifier.on_created_entity(event)
  local purifier = event.created_entity or event.entity or event.destination
  if not (purifier and purifier.valid) then return end

  if purifier.name == "kr-air-purifier" then
    table.insert(global["kr-air-purifiers"], purifier)
    local proxy = construction_robot.deliver(purifier, {["pollution-filter"] = 2})
    global["pollution-filter-deliveries"][script.register_on_entity_destroyed(proxy)] = purifier
  end
end

function kr_air_purifier.on_entity_destroyed(event)
  if global["pollution-filter-deliveries"][event.registration_number] then
    local purifier = global["pollution-filter-deliveries"][event.registration_number]
    global["pollution-filter-deliveries"][event.registration_number] = nil

    if purifier and purifier.valid then

      local used_filters = purifier.get_inventory(defines.inventory.furnace_result)
      if not used_filters.is_empty() then
      -- has empty filters to extract

        local robot = purifier.surface.find_entity("construction-robot", purifier.position)
        if robot then
        -- construction bot still nearby

          local cargo = robot.get_inventory(defines.inventory.robot_cargo)
          if cargo.is_empty() then
          -- bot on the return trip?

            for name, count in pairs(used_filters.get_contents()) do
              cargo.insert({name = name, count = count})
            end

            used_filters.clear()
          end
        end
      end
    end
  end
end

function kr_air_purifier.refill_if_empty(purifier)
  if purifier.get_inventory(defines.inventory.furnace_source).is_empty() then
    if not construction_robot.pending_delivery(purifier) then
      local proxy = construction_robot.deliver(purifier, {["pollution-filter"] = 1})
      global["pollution-filter-deliveries"][script.register_on_entity_destroyed(proxy)] = purifier
    end
  end
end

function kr_air_purifier.every_10_seconds()
  for i = #global["kr-air-purifiers"], 1, -1 do
    local purifier = global["kr-air-purifiers"][i]

    if not purifier.valid then
      table.remove(global["kr-air-purifiers"], i)
    else
      kr_air_purifier.refill_if_empty(purifier)
    end
  end
end

return kr_air_purifier
