-- @feature logistic chests with a deconstruction planner signal of -1 drop unrequested items on the ground
-- @feature logistic chests with a deconstruction planner signal of -2 drop overstocked items on the ground

local on_tick_n = require("__flib__.on-tick-n")

function on_tick_n.expedite(ident)
  local tick_list = global.__flib.on_tick_n[ident.tick]
  if not tick_list or not tick_list[ident.index] then
    return false
  end

  on_tick_n.add(game.tick + 1, tick_list[ident.index])
  tick_list[ident.index] = nil

  return true
end

local pinecone = {}

local deconstruction_planner = {type = "item", name = "deconstruction-planner"}

function pinecone.init()
  global["pinecone"] = {}
  global["pinecone"]["tasks"] = {} -- no gc :o

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "logistic-container"}) do
      pinecone.handle(entity.get_logistic_point(defines.logistic_member_index.logistic_container))
    end
  end
end

function pinecone.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  if entity.type == "logistic-container" then
    pinecone.handle(entity.get_logistic_point(defines.logistic_member_index.logistic_container))
  end
end

function pinecone.handle(logistic_point)
  if not logistic_point or not logistic_point.valid then return end
  local entity = logistic_point.owner
  local cooldown = 6000 -- 100 seconds

  if #entity.circuit_connected_entities.red > 0 or #entity.circuit_connected_entities.green > 0 then
    cooldown = 600 -- 10 seconds

    local signal = entity.get_merged_signal(deconstruction_planner)
    if signal < 0 then
      cooldown = 60 -- 1 second

      local inventory = logistic_point.owner.get_inventory(defines.inventory.chest)
      local stacks = inventory.get_contents()

      if logistic_point.filters then
        for _, filter in pairs(logistic_point.filters) do
          if signal == -1 then stacks[filter.name] = nil end
          if signal == -2 then stacks[filter.name] = math.max(0, stacks[filter.name] - filter.count) end
        end
      end

      for name, count in pairs(stacks) do
        if count > 0 then
          local spilled = {name = name, count = 1}
          entity.surface.spill_item_stack(entity.position, spilled, false, entity.force, false)
          inventory.remove(spilled)
          cooldown = 1 -- 1 tick
          break
        end
      end

    end

  end

  global["pinecone"]["tasks"][entity.unit_number] = on_tick_n.add(game.tick + cooldown, {script = "pinecone", logistic_point = logistic_point})
end

function pinecone.on_task(task)
  pinecone.handle(task.logistic_point)
end

function pinecone.on_selected_entity_changed(event)
  local player = game.get_player(event.player_index)
  if player.selected and player.selected.type == "logistic-container" then
    local ident = global["pinecone"]["tasks"][player.selected.unit_number]
    if ident then on_tick_n.expedite(ident) end
  end
end

return pinecone
