-- @feature nuclear reactors stop using fuel while at max heat
-- @feature construction robots refuel nuclear reactors

local on_tick_n = require("__flib__.on-tick-n")
local construction_robot = require("construction-robot")

local nuclear_reactor = {}

function nuclear_reactor.init()
  global["nuclear-reactor"] = {}

  global["nuclear-reactor"]["deliveries"] = {}

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

local data_raws = {}
local function data_raw(entity)
  if not data_raws[entity.name] then
    local i = string.find(entity.prototype.order, "raw")
    local eval = string.sub(entity.prototype.order, i)
    load(eval)()
    data_raws[entity.name] = raw
  end

  return data_raws[entity.name]
end

function nuclear_reactor.handle(reactor)
  if not reactor or not reactor.valid then return end
  if not reactor.active then reactor.active = true end

  reactor.surface.create_entity{name = "flying-text", position = reactor.position, text = "[item=uranium-fuel-cell]"}

  local prototype = data_raw(reactor)
  local seconds_until_depleted = math.ceil(reactor.burner.remaining_burning_fuel / prototype.consumption)

  if seconds_until_depleted > 0 then
  -- reschedule the handler for when the fuel that currently burns runs out
    on_tick_n.add(game.tick + 1 + (seconds_until_depleted * 60), {script = "nuclear-reactor", entity = reactor})
  else
    if reactor.temperature < (prototype.max_temperature * 0.75) and table_size(reactor.neighbours) < 4 then
    -- request a new fuel cell when temperature drops below 75%
      if not construction_robot.pending_delivery(reactor) then
        local proxy = construction_robot.deliver(reactor, {["uranium-fuel-cell"] = 1})
        global["nuclear-reactor"]["deliveries"][script.register_on_entity_destroyed(proxy)] = reactor
      end
    end

    -- while seconds_until_depleted is zero it means nothing is getting burned and no new fuel was found
    local seconds_per_fuel = game.item_prototypes["uranium-fuel-cell"].fuel_value / prototype.consumption -- 200
    on_tick_n.add(game.tick + 1 + math.floor(seconds_per_fuel * 60 * 0.25), {script = "nuclear-reactor", entity = reactor})
  end
end

function nuclear_reactor.on_task(event)
  nuclear_reactor.handle(task.entity)
end


return nuclear_reactor
