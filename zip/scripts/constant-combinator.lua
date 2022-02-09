-- @feature request stack sizes on the bottom row of ltn combinators

local constant_combinator = {}

function constant_combinator.on_gui_closed(entity)
  --- @type LuaConstantCombinatorControlBehavior?
  local combinator = entity.get_control_behavior()
  if not combinator then return end

  -- store if these signals are present
  local request_stack_threshold = false
  local provide_stack_threshold = false

  local parameters = {}
  local text = {}

  --- @type ConstantCombinatorParameters
  for _, parameter in pairs(combinator.parameters) do

    if parameter.signal.name == "ltn-requester-stack-threshold" then
      request_stack_threshold = true
    elseif parameter.signal.name == "ltn-provider-stack-threshold" then
      provide_stack_threshold = true
    end

    -- you can't modify inside `combinator.parameters`, so keep a copy that can eventually overwrite the original with `combinator.parameters = parameters`
    parameters[parameter.index] = {index = parameter.index, count = parameter.count, signal = {name = parameter.signal.name, type = parameter.signal.type}}
  end

  --- @type ConstantCombinatorParameters
  for _, parameter in pairs(parameters) do
    if parameter.index > 10 then
    -- 2nd row of the combinator

      if parameter.signal.type == "item" and parameter.signal.name ~= nil then
      -- there is an item configured in this slot

        local above = parameters[parameter.index - 10]

        if above.signal.name == nil or (above.signal.type == "item" and above.signal.name == parameter.signal.name) then
        -- the signal above it is either empty or of the same item

          local stack_size = game.item_prototypes[parameter.signal.name].stack_size

          if (parameter.count < 0 and request_stack_threshold) or (parameter.count > 0 and provide_stack_threshold) then
            local old_above_count = above.count

            above.signal.type = parameter.signal.type
            above.signal.name = parameter.signal.name
            above.count = (parameter.count * stack_size) - parameter.count
            parameters[above.index] = above

            if above.count ~= old_above_count then
              table.insert(text, "[item=" .. parameter.signal.name .. "]")
              table.insert(text, parameter.count)
              table.insert(text, "x")
              table.insert(text, stack_size)
              table.insert(text, "=")
              table.insert(text, parameter.count + above.count)
            end
          end

        end
      end
    end
  end

  if #text > 0 then
  -- notify the players of all modified above ones
    entity.surface.create_entity{name = "flying-text", position = entity.position, text = table.concat(text, " ")}
  end

  combinator.parameters = parameters
end

return constant_combinator
