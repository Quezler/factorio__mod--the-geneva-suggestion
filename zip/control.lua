local programmable_speaker = require("scripts.programmable-speaker")
local train_stop           = require("scripts.train-stop")
local rock_repair          = require("scripts.rock-repair")

script.on_event(defines.events.on_gui_closed, function(event)
    if event.gui_type == defines.gui_type.entity then
        if(event.entity.name == "programmable-speaker") then
            programmable_speaker.on_gui_closed(event.entity)
        end
    end
end)

script.on_init(function(event)
    train_stop.on_init(event)
end)

script.on_event(defines.events.on_built_entity, function(event)
    train_stop.on_built_entity(event)
end)

script.on_event(defines.events.on_entity_renamed, function(event)
    train_stop.on_entity_renamed(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    train_stop.on_robot_built_entity(event)
end)

script.on_event(defines.events.on_entity_damaged, function(event)
  rock_repair.on_entity_damaged(event)
end, {{filter = "type", type = "simple-entity"}})

local function init()
  global = {}

  log("Retrieving the royal ordnance L30a1 120mm rifled gun emplacement we have conveniently stored in the basement.")

  rock_repair.init()
end

script.on_configuration_changed(function(event)
  init()
end)

commands.add_command("baguette", "attempt to feed the leclerc main battletank", function(e)
  local player = game.get_player(e.player_index)
  if player.admin then
    init()
  end
end)

script.on_nth_tick(60, function()
  rock_repair.on_nth_tick()
end)
