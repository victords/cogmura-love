require("src.iso_block")
require("src.player_character")
require("src.enemy")
require("src.item")

Exit = setmetatable({}, Rectangle)
Exit.__index = Exit

function Exit.new(dest_scene, dest_entrance, col, row, layer)
  local self = Rectangle.new(col * PHYSICS_UNIT, row * PHYSICS_UNIT, PHYSICS_UNIT, PHYSICS_UNIT)
  setmetatable(self, Exit)
  self.dest_scene = dest_scene
  self.dest_entrance = dest_entrance
  self.layer = layer
  return self
end

SceneParser = {}
SceneParser.__index = SceneParser

local function next_tile(i, j)
  i = i + 1
  if i >= SCENE_TILE_COUNT - (j >= HALF_TILE_COUNT and j - HALF_TILE_COUNT or HALF_TILE_COUNT - 1 - j) then
    j = j + 1
    i = HALF_TILE_COUNT - (j >= HALF_TILE_COUNT and SCENE_TILE_COUNT - j or j + 1)
  end
  return i, j
end

local function fill_tiles(tiles, fill, i, j)
  while j < SCENE_TILE_COUNT - 1 or (j == SCENE_TILE_COUNT - 1 and i < HALF_TILE_COUNT + 1) do
    tiles[i + 1][j + 1] = fill
    i, j = next_tile(i, j)
  end
end

function SceneParser.new(scene)
  local self = setmetatable({}, SceneParser)
  self.scene = scene
  return self
end

function SceneParser:parse()
  local scene = self.scene
  local content = love.filesystem.read("data/scene/" .. scene.index .. ".txt")
  local data = Utils.split(content, "#")

  local tileset_data = Utils.split(data[1], ",")
  scene.tileset_id = tileset_data[1]
  scene.tileset = Res.tileset("tileset/" .. tileset_data[1], 2, 8)
  if tileset_data[2] then scene.fill_tile = tonumber(tileset_data[2]) + 1 end

  local entrance_data = Utils.split(data[2], ";")
  scene.entrances = Utils.map(entrance_data, function(e)
    return Utils.map(Utils.split(e, ","), function(d) return tonumber(d) end)
  end)

  local exit_data = Utils.split(data[3], ";")
  scene.exits = Utils.map(exit_data, function(e)
    local args = Utils.map(Utils.split(e, ","), function(d) return tonumber(d) end)
    return Exit.new(unpack(args))
  end)

  local spawn_point_data = Utils.split(data[4], ";")
  scene.battle_spawn_points = Utils.map(spawn_point_data, function(s)
    return Utils.map(Utils.split(s, ","), function(d) return tonumber(d) end)
  end)

  local object_data = Utils.split(data[5], ";")
  for _, o in ipairs(object_data) do
    local object_type = o:sub(1, 1)
    local args = Utils.split(o:sub(2), ",")
    if object_type ~= "o" then
      args = Utils.map(args, function(a) return tonumber(a) end)
    end
    if object_type == "b" then
      table.insert(scene.blocks, IsoBlock.new(args[1], args[2], args[3], args[4]))
    elseif object_type == "e" then
      table.insert(scene.objects, Enemy.new(args[1], args[2], args[3], args[4]))
    elseif object_type == "i" then
      table.insert(scene.objects, Item.new(args[1], args[2], args[3], args[4]))
    elseif object_type == "w" then
      table.insert(scene.blocks, IsoBlock.new(nil, args[1], args[2], args[3], args[4], args[5], args[6], args[7] ~= nil))
    end
  end

  local i = SCENE_TILE_COUNT / 2 - 1
  local j = 0
  local tile_data = Utils.split(data[6], ";")
  for _, d in ipairs(tile_data) do
    if d:sub(1, 1) == "_" then
      local n = tonumber(d:sub(2))
      for k = 1, n do
        i, j = next_tile(i, j)
      end
    else
      local index = d:find("*", 1, true)
      local tile_type = tonumber(d:sub(1, index and index - 1 or nil))
      local num_tiles = index and tonumber(d:sub(index + 1)) or 1
      for k = 1, num_tiles do
        scene.tiles[i + 1][j + 1] = tile_type + 1
        i, j = next_tile(i, j)
      end
    end
  end

  if tileset_data[2] then
    fill_tiles(scene.tiles, scene.fill_tile, i, j)
  end
end
