local buffer_overflow = {}

function buffer_overflow.init()
  global["buffer-overflow"] = {}
  global["buffer-overflow"]["buffer-logistic-points"] = {} -- keyed by unit_number of the buffer chest
  global["buffer-overflow"]["active-logistic-points"] = {} -- keyed by unit_number of the buffer chest

  for _, force in pairs(game.forces) do
    for _, logistic_networks in pairs(force.logistic_networks) do
      for _, logistic_network in pairs(logistic_networks) do
        for _, logistic_point in pairs(logistic_network.requester_points) do
          buffer_overflow.handle(logistic_point)
        end
      end
    end
  end
end


local function items_without_filters(logistic_point)
  local inventory = logistic_point.owner.get_inventory(defines.inventory.chest)

  -- store all the chest's content
  local stacks = inventory.get_contents()

  if (logistic_point.filters) then
    for _, filter in pairs(logistic_point.filters) do
      -- unset the item name for anything with a filter
      stacks[filter.name] = nil
    end
  end

  -- you're left with all the unwelcome items
  return stacks
end

local directions    = {}
directions["north"] = function(entity) return {{entity.position.x, entity.position.y - 1}, {entity.position.x, entity.position.y}} end
directions["east"]  = function(entity) return {{entity.position.x, entity.position.y}, {entity.position.x + 1, entity.position.y}} end
directions["south"] = function(entity) return {{entity.position.x, entity.position.y}, {entity.position.x, entity.position.y + 1}} end
directions["west"]  = function(entity) return {{entity.position.x - 1, entity.position.y}, {entity.position.x, entity.position.y}} end

local function adjacent_logistic_containers(entity)
  local found_in_the_4_directions = {}

  for direction, area in pairs(directions) do
    local entities = entity.surface.find_entities_filtered({
      area = area(entity),
      type = "logistic-container",
      force = entity.force,
    })

    for _, nearby in pairs(entities) do
      table.insert(found_in_the_4_directions, nearby)
--       if nearby.name ~= entity.name then
--         game.print("Found another logistic container to the " .. direction .. ".")
--       end
    end
  end

  return found_in_the_4_directions
end

function buffer_overflow.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  if entity.type == "logistic-container" then
    buffer_overflow.handle(entity.get_logistic_point(defines.logistic_member_index.logistic_container))
  end
end

function buffer_overflow.handle(logistic_point)

  if logistic_point.mode == defines.logistic_mode.active_provider then
  -- find an existing buffer chest near this freshly placed active one
    for _, nearby in pairs(adjacent_logistic_containers(logistic_point.owner)) do
      nearby_logistic_point = nearby.get_logistic_point(defines.logistic_member_index.logistic_container)
      if nearby_logistic_point.mode == defines.logistic_mode.buffer then
        -- if you find one, pass it on to the if down below
        logistic_point = nearby_logistic_point
      end
    end
  end

  if logistic_point.mode == defines.logistic_mode.buffer then
  -- find an existing active chest near this freshly placed buffer one
    for _, nearby in pairs(adjacent_logistic_containers(logistic_point.owner)) do
      nearby_logistic_point = nearby.get_logistic_point(defines.logistic_member_index.logistic_container)
      if nearby_logistic_point.mode == defines.logistic_mode.active_provider then
      -- if you find one, link them together in a one-way relationship
        -- game.print("✔")
        global["buffer-overflow"]["buffer-logistic-points"][logistic_point.owner.unit_number] = logistic_point
        global["buffer-overflow"]["active-logistic-points"][logistic_point.owner.unit_number] = nearby_logistic_point
      end
    end
  end
end

function buffer_overflow.every_second()
  for _, buffer_logistic_point in pairs(global["buffer-overflow"]["buffer-logistic-points"]) do
    local active_logistic_point = global["buffer-overflow"]["active-logistic-points"][_]

    if not buffer_logistic_point.valid or not active_logistic_point.valid then
      -- game.print("✘")
      global["buffer-overflow"]["buffer-logistic-points"][_] = nil
      global["buffer-overflow"]["active-logistic-points"][_] = nil
    else
      local transfer = items_without_filters(buffer_logistic_point)
      if table_size(transfer) > 0 then

        local buffer_inventory = buffer_logistic_point.owner.get_inventory(defines.inventory.chest)
        local active_inventory = active_logistic_point.owner.get_inventory(defines.inventory.chest)
  
        for name, count in pairs(transfer) do
          local inserted = active_inventory.insert({name = name, count = count})
          buffer_inventory.remove({name = name, count = inserted})
        end
      end
    end
  end
end

return buffer_overflow
