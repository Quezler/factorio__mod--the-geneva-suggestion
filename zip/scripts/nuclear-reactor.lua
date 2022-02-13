-- @feature nuclear reactors stop using fuel while at max heat
-- @feature construction robots refuel nuclear reactors

local construction_robot = require("construction-robot")
local queue = require("__flib__.queue")

local nuclear_reactor = {}

local deactivate_above = 750
local reactivate_under = 750

function nuclear_reactor.init()
  global["nuclear-reactor"] = {}

  global["nuclear-reactor"]["active"] = queue.new()
  global["nuclear-reactor"]["inactive"] = queue.new()
  global["nuclear-reactor"]["deliveries"] = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "reactor", name = "nuclear-reactor"}) do
      if entity.active then
        queue.push_right(global["nuclear-reactor"]["active"], entity)
      else
        queue.push_right(global["nuclear-reactor"]["inactive"], entity)
      end
    end
  end
end

function nuclear_reactor.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  if entity.type == "reactor" and entity.name == "nuclear-reactor" then
    if entity.active then
      queue.push_left(global["nuclear-reactor"]["active"], entity)
    else
      queue.push_left(global["nuclear-reactor"]["inactive"], entity)
    end
  end
end

function nuclear_reactor.on_entity_destroyed(event)
  if global["nuclear-reactor"]["deliveries"][event.registration_number] then
    local reactor = global["nuclear-reactor"]["deliveries"][event.registration_number]
    global["nuclear-reactor"]["deliveries"][event.registration_number] = nil

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

function nuclear_reactor.handle_one_active(reactor)
  local reactor = queue.pop_left(global["nuclear-reactor"]["active"])
  if not reactor or not reactor.valid then return end

  if reactor.temperature > deactivate_above then
    queue.push_right(global["nuclear-reactor"]["inactive"], reactor)
    reactor.active = false
  else
    queue.push_right(global["nuclear-reactor"]["inactive"], reactor)
    if reactor.get_inventory(defines.inventory.fuel).get_item_count() == 0 then

      local surrounded_on_all_sides = reactor.neighbours["north"] ~= nil and reactor.neighbours["east"] ~= nil and reactor.neighbours["south"] ~= nil and reactor.neighbours["west"] ~= nil
      if not surrounded_on_all_sides then

        if not construction_robot.pending_delivery(reactor) then
          local proxy = construction_robot.deliver(reactor, {["uranium-fuel-cell"] = 1})
          global["nuclear-reactor"]["deliveries"][script.register_on_entity_destroyed(proxy)] = reactor
        end
      end
    end
  end
end

function nuclear_reactor.handle_one_inactive(reactor)
  local reactor = queue.pop_left(global["nuclear-reactor"]["inactive"])
  if not reactor or not reactor.valid then return end

  if reactor.temperature < reactivate_under then
    queue.push_right(global["nuclear-reactor"]["active"], reactor)
    reactor.active = true
  else
    queue.push_right(global["nuclear-reactor"]["inactive"], reactor)
  end
end

function nuclear_reactor.every_second()
  if queue.length(global["nuclear-reactor"]["active"]) > 0 then
    nuclear_reactor.handle_one_active()
  end
  if queue.length(global["nuclear-reactor"]["inactive"]) > 0 then
    nuclear_reactor.handle_one_inactive()
  end

--   game.print("active: " .. queue.length(global["nuclear-reactor"]["active"]))
--   game.print("inactive: " .. queue.length(global["nuclear-reactor"]["inactive"]))
end


return nuclear_reactor
