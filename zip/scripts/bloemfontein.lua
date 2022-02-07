-- @feature upgrades inserters/conveyors/loaders on the right side of the 2nd train carriage when a train arrives (if the items are present in the construction network)

local bloemfontein = {}

function bloemfontein.init()
  global["bloemfontein"] = {}
  global["bloemfontein"]["player-highlight-boxes"] = {}
end

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

local function round_bounding_box(bounding_box)
  bounding_box.orientation    = nil
  bounding_box.left_top.x     = math.floor(bounding_box.left_top.x    )
  bounding_box.left_top.y     = math.floor(bounding_box.left_top.y    )
  bounding_box.right_bottom.x = math.floor(bounding_box.right_bottom.x)
  bounding_box.right_bottom.y = math.floor(bounding_box.right_bottom.y)
  return bounding_box
end

local orientation_north = 0
local orientation_east = 0.25
local orientation_south = 0.5
local orientation_west = 0.75

local function cargo_area_for_station(station)
    local bounding_box = round_bounding_box(station.bounding_box)

    if station.orientation == orientation_north then
      bounding_box.right_bottom.y = bounding_box.right_bottom.y + 13 -- next to rail facing station
      bounding_box.left_top.y     = bounding_box.left_top.y     + 8  -- next to rail !facing station
      bounding_box.right_bottom.x = bounding_box.right_bottom.x + 2  -- thickness :3
    elseif station.orientation == orientation_east then
      bounding_box.left_top.x     = bounding_box.left_top.x     - 12 -- next to rail facing station
      bounding_box.right_bottom.x = bounding_box.right_bottom.x - 7  -- next to rail !facing station
      bounding_box.right_bottom.y = bounding_box.right_bottom.y + 2  -- thickness :3
    elseif station.orientation == orientation_south then
      bounding_box.right_bottom.x = bounding_box.right_bottom.x + 1  -- next to rail facing station
      bounding_box.right_bottom.y = bounding_box.right_bottom.y - 7  -- next to rail facing station
      bounding_box.left_top.y     = bounding_box.left_top.y     - 12 -- next to rail !facing station
      bounding_box.left_top.x     = bounding_box.left_top.x     - 1  -- thickness :3
    elseif station.orientation == orientation_west then
      bounding_box.left_top.x     = bounding_box.left_top.x     + 8  -- next to rail facing station
      bounding_box.right_bottom.x = bounding_box.right_bottom.x + 13 -- next to rail !facing station
      bounding_box.right_bottom.y = bounding_box.right_bottom.y + 1  -- next to rail !facing station
      bounding_box.left_top.y     = bounding_box.left_top.y     - 1  -- thickness :3
    end

    return bounding_box
end

function bloemfontein.on_selected_entity_changed(event)
  if global["bloemfontein"]["player-highlight-boxes"][event.player_index] then
     global["bloemfontein"]["player-highlight-boxes"][event.player_index].destroy()
     global["bloemfontein"]["player-highlight-boxes"][event.player_index] = nil
  end

  local player = game.get_player(event.player_index)
  if player.selected and player.selected.type == "train-stop" then

    local station = player.selected

    local highlight_box = station.surface.create_entity({name = "highlight-box", box_type = "train-visualization", position = station.position, bounding_box = cargo_area_for_station(station), time_to_live = 60 * 60})
    global["bloemfontein"]["player-highlight-boxes"][event.player_index] = highlight_box
  end
end

function bloemfontein.on_train_changed_state(event)
  if event.train.state == defines.train_state.wait_station then
  -- arrived at a train stop
    if event.train.station then
    -- stop is not temporary
      local upgradables = event.train.station.surface.find_entities_filtered({area = cargo_area_for_station(event.train.station), type = {"inserter", "transport-belt", "loader-1x1"}, force = event.train.station.force})
      for _, upgradable in pairs(upgradables) do
        if not upgradable.to_be_upgraded() and upgradable.prototype.next_upgrade and upgrade_item_available(upgradable) then
          upgradable.order_upgrade({force = upgradable.force, target = upgradable.prototype.next_upgrade.name})
        end
      end
    end
  end
end

return bloemfontein
