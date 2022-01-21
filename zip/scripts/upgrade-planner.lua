local util = require("util")

local upgrade_planner = {}

function upgrade_planner.on_marked_for_upgrade(event)
    if event.entity.force.recipes[event.target.name] then
        if not event.entity.force.recipes[event.target.name].enabled then
            event.entity.cancel_upgrade(event.entity.force)
            util.floater(event.entity, "[item=" .. event.target.name .. "] not yet unlocked")
        end
    end
end

return upgrade_planner
