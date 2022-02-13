-- @feature nuclear reactors stop using fuel while at max heat
-- @feature construction robots refuel nuclear reactors

-- assume a reactor can heat up by 10 heat per second

local queue = require("__flib__.queue")
local on_tick_n = require("__flib__.on-tick-n")
local construction_robot = require("construction-robot")

local nuclear_reactor = {}

local deactivate_above = 750
local reactivate_under = 750

function nuclear_reactor.init()
  global["nuclear-reactor"] = {}

--   global["nuclear-reactor"]["active"] = queue.new()
--   global["nuclear-reactor"]["inactive"] = queue.new()
--   global["nuclear-reactor"]["deliveries"] = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "reactor", name = "nuclear-reactor"}) do
      nuclear_reactor.handle(entity)
    end
  end
end

function nuclear_reactor.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  if entity.type == "reactor" and entity.name == "nuclear-reactor" then
    nuclear_reactor.handle(entity)
  end
end

-- function nuclear_reactor.on_entity_destroyed(event)
--   if global["nuclear-reactor"]["deliveries"][event.registration_number] then
--     local reactor = global["nuclear-reactor"]["deliveries"][event.registration_number]
--     global["nuclear-reactor"]["deliveries"][event.registration_number] = nil
--
--     if reactor and reactor.valid then
--
--       local used = reactor.get_inventory(defines.inventory.burnt_result)
--       if not used.is_empty() then
--
--         local robot = reactor.surface.find_entity("construction-robot", reactor.position)
--         if robot then
--
--           local cargo = robot.get_inventory(defines.inventory.robot_cargo)
--           if cargo.is_empty() then
--
--             for name, count in pairs(used.get_contents()) do
--               cargo.insert({name = name, count = count})
--             end
--
--             used.clear()
--           end
--         end
--       end
--     end
--   end
-- end

-- function nuclear_reactor.handle_one_active(reactor)
--   local reactor = queue.pop_left(global["nuclear-reactor"]["active"])
--   if not reactor or not reactor.valid then return end
--
--   if reactor.temperature > deactivate_above then
--     queue.push_right(global["nuclear-reactor"]["inactive"], reactor)
--     reactor.active = false
--   else
--     queue.push_right(global["nuclear-reactor"]["inactive"], reactor)
--     if reactor.get_inventory(defines.inventory.fuel).get_item_count() == 0 then
--
--       if table_size(reactor.neighbours) < 4 then
--
--         if not construction_robot.pending_delivery(reactor) then
--           local proxy = construction_robot.deliver(reactor, {["uranium-fuel-cell"] = 1})
--           global["nuclear-reactor"]["deliveries"][script.register_on_entity_destroyed(proxy)] = reactor
--         end
--       end
--     end
--   end
-- end

-- function nuclear_reactor.handle_one_inactive(reactor)
--   local reactor = queue.pop_left(global["nuclear-reactor"]["inactive"])
--   if not reactor or not reactor.valid then return end
--
--   if reactor.temperature < reactivate_under then
--     queue.push_right(global["nuclear-reactor"]["active"], reactor)
--     reactor.active = true
--   else
--     queue.push_right(global["nuclear-reactor"]["inactive"], reactor)
--   end
-- end

-- function nuclear_reactor.every_second()
--   if queue.length(global["nuclear-reactor"]["active"]) > 0 then
--     nuclear_reactor.handle_one_active()
--   end
--   if queue.length(global["nuclear-reactor"]["inactive"]) > 0 then
--     nuclear_reactor.handle_one_inactive()
--   end
--
-- --   game.print("active: " .. queue.length(global["nuclear-reactor"]["active"]))
-- --   game.print("inactive: " .. queue.length(global["nuclear-reactor"]["inactive"]))
-- end

function nuclear_reactor.handle(reactor)
  if not reactor or not reactor.valid then return end

  reactor.surface.create_entity{name = "flying-text", position = reactor.position, text = "meltdown?"}
  if reactor.temperature > 999 then
    reactor.active = false
  end

  if reactor.active then
    local max_temperature           = 1000 -- data.raw["reactor"]["nuclear-reactor"].heat_buffer.max_temperature
    local consumption   = 40 * 1000 * 1000 -- data.raw["reactor"]["nuclear-reactor"].consumption = "40MW"
    local specific_heat = 10 * 1000 * 1000 -- data.raw["reactor"]["nuclear-reactor"].heat_buffer.specific_heat = "10MJ"
--     local productivity  = 1 + table_size(reactor.neighbours) * reactor.prototype.neighbour_bonus

    local seconds_till_meltdown = (max_temperature - reactor.temperature) * specific_heat / (consumption * productivity) -- 250 @ 0° (246.25 @ 15°)
    on_tick_n.add(game.tick + 1 + math.ceil(seconds_till_meltdown * 60), {name = "nuclear-reactor", entity = reactor})
  end
end

function nuclear_reactor.on_tick(event)
  for _, task in pairs(on_tick_n.retrieve(event.tick) or {}) do
    if task.name == "nuclear-reactor" then
      nuclear_reactor.handle(task.entity)
    end
  end
end


return nuclear_reactor
