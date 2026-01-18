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
  return self
end

SceneParser = {}
SceneParser.__index = SceneParser

function SceneParser.new(scene)
  local self = setmetatable({}, SceneParser)
  self.scene = scene
  return self
end

function SceneParser:parse()
  local scene = self.scene
  local content = love.filesystem.read("data/scene/" .. scene.index .. ".txt")
  local info, entrances, exits, spawn_points, objects, tiles = Utils.split(content, "#")

  local tileset_id, fill_tile = Utils.split(info, ",")
  scene.tileset_id = tileset_id
  scene.tileset = Res.tileset(tileset_id, 1, 7)
  if fill_tile then scene.fill_tile = tonumber(fill_tile) end

  local entrance_data = Utils.split(entrances, ";")
  scene.entrances = Utils.map(entrance_data, function(e)
    return Utils.map(Utils.split(e, ","), function(d) return tonumber(d) end)
  end)

  local exit_data = Utils.split(exits, ";")
  scene.exits = Utils.map(exit_data, function(e)
    local args = Utils.map(Utils.split(e, ","), function(d) return tonumber(d) end)
    return Exit.new(unpack(args))
  end)

  local spawn_point_data = Utils.split(spawn_points, ";")
  scene.spawn_points = Utils.map(spawn_point_data, function(s)
    return Utils.map(Utils.split(s, ","), function(d) return tonumber(d) end)
  end)

  local object_data = Utils.split(objects, ";")
  for _, o in ipairs(object_data) do
    d = o[1..].split(',')
    d = d.map(&:to_i) unless o[0] == 'o'
    case o[0]
    when 'b' # textured block
      @blocks << IsoBlock.new(d[0], d[1], d[2], d[3])
    when 'e'
      @enemies << Enemy.new(d[0], d[1], d[2], d[3], method(:on_enemy_encounter))
    when 'i'
      @items << Item.new(d[0], d[1], d[2], d[3], method(:on_item_picked_up))
    when 'n'
      @npcs << Npc.new(d[0], d[1], d[2], d[3])
    when 'o'
      obj_class = OBJECT_CLASSES[d[0].to_i]
      @objects << obj_class.new(d[1].to_i, d[2].to_i, d[3].to_i, d[4..])
    when 'w' # invisible block
      @blocks << IsoBlock.new(nil, d[0], d[1], d[4] || 0, d[2], d[3], 999, d[5])
    end
  end

  i = M_S / 2 - 1; j = 0
  tiles.split(';').each do |d|
    if d[0] == '_'
      d[1..].to_i.times { i, j = next_tile(i, j) }
      next
    end

    tile_type = d.to_i
    index = d.index('*')
    num_tiles = index ? d[(index + 1)..].to_i : 1
    num_tiles.times do
      @tiles[i][j] = tile_type
      i, j = next_tile(i, j)
    end
  end

  fill_tiles(@fill_tile, i, j) if @fill_tile
end

def fill_tiles(fill, i, j)
  while j < M_S - 1 || j == M_S - 1 && i < M_S / 2 + 1
    @tiles[i][j] = fill.to_i
    i, j = next_tile(i, j)
  end
end

def init_player(entrance_index)
  entrance = @entrances[entrance_index]
  @man = Character.new(entrance.col, entrance.row, entrance.layer)
  @man.on_exit = method(:on_player_leave)
end

def init_transition
  @fading = :in
  @overlay_alpha = 255
end

private

def next_tile(i, j)
  i += 1
  if i >= M_S - (j >= M_S / 2 ? j - M_S / 2 : M_S / 2 - 1 - j)
    j += 1
    i = M_S / 2 - (j >= M_S / 2 ? M_S - j : j + 1)
  end
  [i, j]
end
