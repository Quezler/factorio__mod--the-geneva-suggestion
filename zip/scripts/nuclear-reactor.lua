-- @feature nuclear reactors stop using fuel while at max heat
-- @feature construction robots refuel nuclear reactors

local construction_robot = require("construction-robot")

local nuclear_reactor = {}

local critical_threshold = 900
local meltdown_threshold = 990

function nuclear_reactor.init()
  global["nuclear-reactor"] = {}

  global["nuclear-reactor"]["all"] = {}
  global["nuclear-reactor"]["critical"] = {}
  global["nuclear-reactor"]["meltdown"] = {}
  global["nuclear-reactor"]["resupply"] = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "reactor", name = "nuclear-reactor"}) do
      table.insert(global["nuclear-reactor"]["all"], entity)
    end
  end
end

function nuclear_reactor.on_created_entity(event)
  local reactor = event.created_entity or event.entity or event.destination
  if not (reactor and reactor.valid) then return end

  if reactor.type == "reactor" and reactor.name == "nuclear-reactor" then
    table.insert(global["nuclear-reactor"]["all"], reactor)
  end
end

function nuclear_reactor.on_entity_destroyed(event)
  if global["nuclear-reactor"]["resupply"][event.registration_number] then
    local reactor = global["nuclear-reactor"]["resupply"][event.registration_number]
    global["nuclear-reactor"]["resupply"][event.registration_number] = nil

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

-- loop all reactors every 10 seconds
function nuclear_reactor.every_10_seconds()
  for i = #global["nuclear-reactor"]["all"], 1, -1 do
    local reactor = global["nuclear-reactor"]["all"][i]

    if not reactor.valid then
      table.remove(global["nuclear-reactor"]["all"], i)
    else
      if reactor.temperature > critical_threshold then
        global["nuclear-reactor"]["critical"][reactor.unit_number] = reactor
      else
        reactor.active = true
      end

      if reactor.get_inventory(defines.inventory.fuel).get_item_count() == 0 then

        local surrounded_on_all_sides = reactor.neighbours["north"] ~= nil and reactor.neighbours["east"] ~= nil and reactor.neighbours["south"] ~= nil and reactor.neighbours["west"] ~= nil
        if not surrounded_on_all_sides then

          if not construction_robot.pending_delivery(reactor) then
            local proxy = construction_robot.deliver(reactor, {["uranium-fuel-cell"] = 1})
            global["nuclear-reactor"]["resupply"][script.register_on_entity_destroyed(proxy)] = reactor
          end
        end
      end
    end
  end

  -- game.print("critical: " .. table_size(global["nuclear-reactor"]["critical"]))
  -- game.print("meltdown: " .. table_size(global["nuclear-reactor"]["meltdown"]))
end

-- reactors that are above `critical_threshold` should be checked more often
function nuclear_reactor.every_second()
  for unit_number, reactor in pairs(global["nuclear-reactor"]["critical"]) do

    if not reactor.valid or reactor.temperature < critical_threshold then
      global["nuclear-reactor"]["critical"][unit_number] = nil
    else
      if reactor.temperature > meltdown_threshold then
        global["nuclear-reactor"]["meltdown"][reactor.unit_number] = reactor
      else
        reactor.active = true
      end
    end
  end
end

-- reactors above the `meltdown_threshold` it will get monitored every tick
function nuclear_reactor.every_tick()
  for unit_number, reactor in pairs(global["nuclear-reactor"]["meltdown"]) do

    if not reactor.valid or reactor.temperature < meltdown_threshold then
      global["nuclear-reactor"]["meltdown"][unit_number] = nil
    else
      if reactor.temperature == 1000 then
         reactor.active = false
      else
         reactor.active = true
      end
    end
  end
end

return nuclear_reactor
