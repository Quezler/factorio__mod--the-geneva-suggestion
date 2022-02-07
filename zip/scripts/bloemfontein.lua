local bloemfontein = {}

local upgrade_area_total_tiles = 6 * 3

local function upgrade_item_available(upgradable)
  local networks = upgradable.surface.find_logistic_networks_by_construction_area(upgradable.position, upgradable.force)

  for _, network in pairs(networks) do
    if network.get_item_count(upgradable.prototype.next_upgrade.items_to_place_this[1].name) >= upgrade_area_total_tiles then
    -- avoid upgrading until there is enough to upgrade every tile in this area,
    -- normally there would just be 6 of each (miniloader, conveyor & loader),
    -- so the x3 is just a safety margin for duplicates and race conditions.
      return true
    end
  end

  return false
end

local orientation_north = 0
local orientation_east = 0.25
local orientation_south = 0.5
local orientation_west = 0.75

local function area_right_of_carriage(carriage)
  local bounding_box = carriage.selection_box

  bounding_box.orientation    = nil
  bounding_box.left_top.x     = math.floor(bounding_box.left_top.x    )
  bounding_box.left_top.y     = math.floor(bounding_box.left_top.y    )
  bounding_box.right_bottom.x = math.floor(bounding_box.right_bottom.x)
  bounding_box.right_bottom.y = math.floor(bounding_box.right_bottom.y)

  if carriage.orientation     == orientation_west then
    bounding_box.left_top.x     = bounding_box.left_top.x     - 2
    bounding_box.right_bottom.x = bounding_box.right_bottom.x + 2
    bounding_box.right_bottom.y = bounding_box.right_bottom.y - 3
  elseif carriage.orientation == orientation_south then
    bounding_box.left_top.x     = bounding_box.left_top.x     - 3
    bounding_box.right_bottom.x = bounding_box.right_bottom.x - 2
  elseif carriage.orientation == orientation_east then
    bounding_box.left_top.x     = bounding_box.left_top.x     - 2
    bounding_box.left_top.y     = bounding_box.left_top.y     + 5
    bounding_box.right_bottom.x = bounding_box.right_bottom.x + 2
    bounding_box.right_bottom.y = bounding_box.right_bottom.y + 2
  elseif carriage.orientation == orientation_north then
    bounding_box.left_top.x     = bounding_box.left_top.x     + 2
    bounding_box.right_bottom.x = bounding_box.right_bottom.x + 3
  else
    return nil -- not perfectly aligned to either axis :(
  end

  return bounding_box
end

local function handle_cargo_wagon(cargo_wagon)
  local bounding_box = area_right_of_carriage(cargo_wagon)
  if    bounding_box == nil then return end

  cargo_wagon.surface.create_entity({name = "highlight-box", box_type = "train-visualization", position = cargo_wagon.position, bounding_box = bounding_box, time_to_live = 60 * 5})

  local upgradables = cargo_wagon.surface.find_entities_filtered({area = bounding_box, type = {"inserter", "transport-belt", "loader-1x1"}, force = cargo_wagon.force})
  for _, upgradable in pairs(upgradables) do
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
