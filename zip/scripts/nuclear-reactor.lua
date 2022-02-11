-- @feature nuclear reactors stop using fuel while at max heat

local nuclear_reactor = {}

local critical_threshold = 900
local meltdown_threshold = 990

function nuclear_reactor.init()
  global["nuclear-reactor"] = {}

  global["nuclear-reactor"]["all"] = {}
  global["nuclear-reactor"]["critical"] = {}
  global["nuclear-reactor"]["meltdown"] = {}

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
