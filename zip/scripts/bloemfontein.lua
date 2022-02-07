local bloemfontein = {}

local function upgrade_item_available(upgradable)
  local networks = upgradable.surface.find_logistic_networks_by_construction_area(upgradable.position, upgradable.force)

  for _, network in pairs(networks) do
    if network.get_item_count(upgradable.prototype.next_upgrade.items_to_place_this[1].name) > 0 then
      return true
    end
  end

  return false
end

local function handle_cargo_wagon(cargo_wagon)
  local bounding_box = cargo_wagon.selection_box

  if not (bounding_box.orientation == nil or bounding_box.orientation == 0.25 or bounding_box.orientation == 0.5 or bounding_box.orientation == 0.75) then
  -- wagon is not perfectly horizontal or vertical
    return
  end

  local horizontal = bounding_box.orientation ~= nil
  bounding_box.orientation = nil

  if not horizontal then
    bounding_box.left_top.x     = bounding_box.left_top.x     - 3
    bounding_box.right_bottom.x = bounding_box.right_bottom.x + 3

    bounding_box.left_top.y     = math.floor(bounding_box.left_top.y)
    bounding_box.right_bottom.y = math.floor(bounding_box.right_bottom.y)
  else
    bounding_box.left_top.x     = math.floor(bounding_box.left_top.x     - 2)
    bounding_box.right_bottom.x = math.floor(bounding_box.right_bottom.x + 2)

    bounding_box.left_top.y     = math.floor(bounding_box.left_top.y     - 0)
    bounding_box.right_bottom.y = math.floor(bounding_box.right_bottom.y + 2)
  end

  local highlight_box = cargo_wagon.surface.create_entity({name = "highlight-box", box_type = "copy", position = cargo_wagon.position, bounding_box = bounding_box, time_to_live = 60 * 5})

  local upgradables = cargo_wagon.surface.find_entities_filtered({area = bounding_box, type = {"inserter", "transport-belt", "loader-1x1"}, force = cargo_wagon.force})
  for _, upgradable in pairs(upgradables) do
    game.print( _ .. upgradable.name )

    if not upgradable.to_be_upgraded() and upgradable.prototype.next_upgrade and upgrade_item_available(upgradable) then
      upgradable.order_upgrade({force = upgradable.force, target = upgradable.prototype.next_upgrade.name})
    end
  end
end

function bloemfontein.on_train_changed_state(event)
  if event.train.state == defines.train_state.wait_station then
  -- arrived at a train stop
    if event.train.station then
    -- stop is not temporary
      for _, cargo_wagon in pairs(event.train.cargo_wagons) do
        handle_cargo_wagon(cargo_wagon)
      end
    end
  end
end

return bloemfontein
