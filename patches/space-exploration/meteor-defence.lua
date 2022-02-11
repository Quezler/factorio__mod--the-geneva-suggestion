-- @feature copy pasting meteor defence on logistic chest sets an ammo request

-- data-updates.lua
if mods["space-exploration"] then
  local names_of_logistic_containers_with_request_slots = {}

  for _, logistic_container in pairs(data.raw["logistic-container"]) do
    if logistic_container.logistic_mode == "requester" or logistic_container.logistic_mode == "buffer" then
      table.insert(names_of_logistic_containers_with_request_slots, logistic_container.name)
    end
  end

  data.raw["ammo-turret"]["se-meteor-point-defence-container"].additional_pastable_entities = names_of_logistic_containers_with_request_slots
  data.raw["ammo-turret"]["se-meteor" .. "-defence-container"].additional_pastable_entities = names_of_logistic_containers_with_request_slots

  log("names_of_logistic_containers_with_request_slots:\n" .. serpent.block(names_of_logistic_containers_with_request_slots))
end
