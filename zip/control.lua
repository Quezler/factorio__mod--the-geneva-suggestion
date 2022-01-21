local programmable_speaker = require("scripts.programmable-speaker")
local train_stop           = require("scripts.train-stop")
local upgrade_planner      = require("scripts.upgrade-planner")

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

script.on_event(defines.events.on_marked_for_upgrade, function(event)
    upgrade_planner.on_marked_for_upgrade(event)
end)
