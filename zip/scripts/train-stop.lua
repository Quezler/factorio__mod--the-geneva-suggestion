-- @feature converts rich text to their [img= variant on gui close (helps with LTN)

local util = require("util")

local train_stop = {}

local function rename(train_stop)
    local backer_name = train_stop.backer_name

      backer_name = backer_name:gsub("%[item="           , "[img=item/")
      backer_name = backer_name:gsub("%[entity="         , "[img=entity/")
      backer_name = backer_name:gsub("%[recipe="         , "[img=recipe/")
      backer_name = backer_name:gsub("%[item%-group="    , "[img=item-group/")
      backer_name = backer_name:gsub("%[fluid="          , "[img=fluid/")
      backer_name = backer_name:gsub("%[tile="           , "[img=tile/")
      backer_name = backer_name:gsub("%[virtual%-signal=", "[img=virtual-signal/")

    if(train_stop.backer_name ~= backer_name) then
        train_stop.backer_name = backer_name
        util.floater(train_stop, backer_name)
    end
end

local function dirty(entity)
    if (entity.type == "train-stop") then
        rename(entity)
    end
end

function train_stop.on_init(event)
    for _, train_stop in pairs(game.get_train_stops{}) do
        rename(train_stop)
    end
end

function train_stop.on_built_entity(event)
    dirty(event.created_entity)
end

function train_stop.on_entity_renamed(event)
    dirty(event.entity)
end

function train_stop.on_robot_built_entity(event)
    dirty(event.created_entity)
end

return train_stop
