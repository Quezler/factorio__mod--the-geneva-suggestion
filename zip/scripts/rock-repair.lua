local rock_repair = {}

local function in_array(entity)
  for _, e in pairs(global.healing_per_tick) do
    if e.valid and entity.surface.index == e.surface.index and entity.position.x == e.position.x and entity.position.y == e.position.y then
      return true
    end
  end
  return false
end

function rock_repair.init()
  global.healing_per_tick = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "simple-entity"}) do
      rock_repair.attempt(entity)
    end
  end
end

function rock_repair.on_entity_damaged(event)
  rock_repair.attempt(event.entity)
end

function rock_repair.attempt(entity)
  if 1 > entity.get_health_ratio() then
    if string.find(entity.name, "rock") then
      if not in_array(entity) then
        table.insert(global.healing_per_tick, entity)
      end
    end
  end
end

function rock_repair.on_nth_tick()
  for i = #global.healing_per_tick, 1, -1 do
    local entity = global.healing_per_tick[i]

    if entity.valid and 1 > entity.get_health_ratio() then
      entity.health = entity.health + 0.01 * 60
      -- print("✘ " .. entity.name)
    else
      table.remove(global.healing_per_tick, i)
      -- print("✔ " .. entity.name)
    end
  end
end

return rock_repair
