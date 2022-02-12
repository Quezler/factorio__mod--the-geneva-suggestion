-- @feature nuclear reactors stop using fuel while at max heat
-- @feature construction robots refuel nuclear reactors

local construction_robot = require("construction-robot")
local queue = require("__flib__.queue")

local nuclear_reactor = {}

-- local deactivate_above =
-- local reactivate_above =

function nuclear_reactor.init()
  global["nuclear-reactor"] = {}

  global["nuclear-reactor"]["all"] = queue.new()
  global["nuclear-reactor"]["overheated"] = queue.new()
  global["nuclear-reactor"]["proxied"] = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "reactor", name = "nuclear-reactor"}) do
      queue.push_right(global["nuclear-reactor"]["all"], entity)
    end
  end
end

function nuclear_reactor.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  if entity.type == "reactor" and entity.name == "nuclear-reactor" then
    queue.push_left(global["nuclear-reactor"]["all"], entity)
  end
end

function nuclear_reactor.on_entity_destroyed(event)
  if global["nuclear-reactor"]["proxied"][event.registration_number] then
    local reactor = global["nuclear-reactor"]["proxied"][event.registration_number]
    global["nuclear-reactor"]["proxied"][event.registration_number] = nil

    if reactor and reactor.valid then

      local used = reactor.get_inventory(defines.inventory.burnt_result)
      if not used.is_empty() then

        local robot = reactor.surface.find_entity("construction-robot", reactor.position)
        if robot then

          local cargo = robot.get_inventory(defines.inventory.robot_cargo)
          if cargo.is_empty() then

            for name, count in pairs(used.get_contents()) do
              cargo.insert({name = name, count = count})
            end

            used.clear()
          end
        end
      end
    end
  end
end

function nuclear_reactor.once()
  local reactor = queue.pop_left(global["nuclear-reactor"]["all"])
  if not reactor or not reactor.valid then return end

  if not reactor.active and reactor.temperature < 750 then
    reactor.active = true
  elseif reactor.active and reactor.temperature > 750 then
    reactor.active = false
  end

  if reactor.get_inventory(defines.inventory.fuel).get_item_count() == 0 then

    local surrounded_on_all_sides = reactor.neighbours["north"] ~= nil and reactor.neighbours["east"] ~= nil and reactor.neighbours["south"] ~= nil and reactor.neighbours["west"] ~= nil
    if not surrounded_on_all_sides then

      if not construction_robot.pending_delivery(reactor) then
        local proxy = construction_robot.deliver(reactor, {["uranium-fuel-cell"] = 1})
        global["nuclear-reactor"]["proxied"][script.register_on_entity_destroyed(proxy)] = reactor
      end
    end
  end

  queue.push_right(global["nuclear-reactor"]["all"], reactor)
end

function nuclear_reactor.every_second()
  -- ensure each reactor is serviced at least once every 100 seconds
  for i = 0, math.ceil(queue.length(global["nuclear-reactor"]["all"]) / 100), 1 do
    nuclear_reactor.once()
  end
end


return nuclear_reactor
