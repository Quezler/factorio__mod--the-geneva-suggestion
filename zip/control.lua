local programmable_speaker = require("scripts.programmable-speaker")
local train_stop           = require("scripts.train-stop")
local rock_repair          = require("scripts.rock-repair")
local kr_air_purifier      = require("scripts.kr-air-purifier")
local buffer_overflow      = require("scripts.buffer-overflow")

-- init

local function init()
  global = {}

  log("Retrieving the royal ordnance L30a1 120mm rifled gun emplacement we have conveniently stored in the basement.")

  train_stop.on_init()
  rock_repair.init()
  kr_air_purifier.init()
  buffer_overflow.init()
end

script.on_init(function()
  init()
end)

script.on_configuration_changed(function(event)
  init()
end)

-- events

script.on_event(defines.events.on_gui_closed, function(event)
  if event.gui_type == defines.gui_type.entity then
    if(event.entity.name == "programmable-speaker") then
      programmable_speaker.on_gui_closed(event.entity)
    end
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  train_stop.on_built_entity(event)
  kr_air_purifier.on_created_entity(event)
  buffer_overflow.on_created_entity(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  train_stop.on_robot_built_entity(event)
  kr_air_purifier.on_created_entity(event)
  buffer_overflow.on_created_entity(event)
end)

script.on_event(defines.events.script_raised_built, function(event)
  kr_air_purifier.on_created_entity(event)
  buffer_overflow.on_created_entity(event)
end)

script.on_event(defines.events.script_raised_revive, function(event)
  kr_air_purifier.on_created_entity(event)
  buffer_overflow.on_created_entity(event)
end)

script.on_event(defines.events.on_entity_cloned, function(event)
  kr_air_purifier.on_created_entity(event)
  buffer_overflow.on_created_entity(event)
end)

script.on_event(defines.events.on_entity_renamed, function(event)
  train_stop.on_entity_renamed(event)
end)

script.on_event(defines.events.on_entity_damaged, function(event)
  rock_repair.on_entity_damaged(event)
end, {{filter = "type", type = "simple-entity"}})

script.on_event(defines.events.on_entity_destroyed, function(event)
  kr_air_purifier.on_entity_destroyed(event)
end)

script.on_event(defines.events.on_player_clicked_gps_tag, function(event)
  local player = game.get_player(event.player_index)
  if player.cursor_stack and player.cursor_stack.valid_for_read then
  -- hand was not empty while gps tag was clicked
    player.zoom_to_world(player.position)
  end
end)

-- commands

commands.add_command("baguette", "- Attempt to feed the leclerc main battletank.", function(event)
  local player = game.get_player(event.player_index)
  if player.admin then
    init()
  end
end)

commands.add_command("se-blueprint-space-rail-ify", "- Replaces normal rails with space rails.", function(event)
 local player = game.get_player(event.player_index)
 local stack = player.cursor_stack
 if stack.is_blueprint or stack.is_blueprint_book then

   local blueprint = stack.export_stack()
   blueprint = string.gsub(blueprint, "^0", "")
   blueprint = game.decode_string(blueprint)

   blueprint = string.gsub(blueprint, "\"straight%-rail\"", "\"se-space-straight-rail\"")
   blueprint = string.gsub(blueprint, "\"curved%-rail\"", "\"se-space-curved-rail\"")

   blueprint = game.encode_string(blueprint)
   blueprint = "0" .. blueprint
   stack.import_stack(blueprint)
 end
end)

-- ticks

script.on_nth_tick(60 * 1, function()
  rock_repair.on_nth_tick()
  kr_air_purifier.on_nth_tick()
  buffer_overflow.every_second()
end)
