require("src.scene_parser")

Scene = {}
Scene.__index = Scene

local function draw_tile(color, x, y)
  Window.draw_polygon(1, color, "fill", x + HALF_TILE_WIDTH, y, x + TILE_WIDTH, y + HALF_TILE_HEIGHT, x + HALF_TILE_WIDTH, y + TILE_HEIGHT, x, y + HALF_TILE_HEIGHT)
end

function Scene.new(index, entrance_index)
  local self = setmetatable({}, Scene)
  self.index = index

  self.map = Map.new(TILE_WIDTH, TILE_HEIGHT, SCENE_TILE_COUNT, SCENE_TILE_COUNT, Window.reference_width, Window.reference_height, true, false)
  self.map:set_camera(SCENE_TILE_COUNT / 4 * TILE_WIDTH, SCENE_TILE_COUNT / 4 * TILE_HEIGHT - SCENE_CAMERA_OFFSET)
  self.blocks = {
    IsoBlock.new(nil, 0, HALF_TILE_COUNT - 1, 0, HALF_TILE_COUNT, 1, 99, true),
    IsoBlock.new(nil, -0.5, HALF_TILE_COUNT + 0.5, 0, 1, HALF_TILE_COUNT, 99, true),
    IsoBlock.new(nil, HALF_TILE_COUNT + 0.5, SCENE_TILE_COUNT - 0.5, 0, HALF_TILE_COUNT, 1, 99, true),
    IsoBlock.new(nil, HALF_TILE_COUNT + 0.5, -0.5, 0, 1, HALF_TILE_COUNT, 99, true),
  }
  self.objects = {}
  self.tiles = {}
  for i = 1, SCENE_TILE_COUNT do
    table.insert(self.tiles, {})
    for j = 1, SCENE_TILE_COUNT do
      table.insert(self.tiles[i], 0)
    end
  end
  SceneParser.new(self):parse()

  entrance_index = entrance_index or 1
  local entrance = self.entrances[entrance_index]
  self.player_character = PlayerCharacter.new(entrance[1], entrance[2], entrance[3])
  self.fading = true
  self.active = true

  EventManager.listen("player_move_start", Scene.prepare_obstacles, self)
  EventManager.listen("battle_start", Scene.on_battle_start, self)
  EventManager.listen("battle_finish", Scene.on_battle_finish, self)
  EventManager.listen("fade_finish", function() self.fading = false end)

  return self
end

function Scene:activate(entrance_index)
  if entrance_index then
    local entrance = self.entrances[entrance_index]
    self.player_character:move_to(entrance[1], entrance[2], entrance[3])
  end
  self.player_character:activate()
  for _, o in ipairs(self.objects) do
    o:activate()
  end
  for _, b in ipairs(self.blocks) do
    b:activate()
  end
  self.active = true
end

function Scene:deactivate()
  self.player_character:deactivate()
  for _, o in ipairs(self.objects) do
    o:deactivate()
  end
  for _, b in ipairs(self.blocks) do
    b:deactivate()
  end
  self.active = false
end

function Scene:prepare_obstacles(player_z, player_height)
  if not self.active then return end

  for _, block in ipairs(self.blocks) do
    block:set_body_active(block.top > player_z + STEP_THRESHOLD and player_z + player_height > block.z)
  end
end

function Scene:on_battle_start()
  if not self.active then return end

  self.in_battle = true
  self:deactivate()
end

function Scene:on_battle_finish()
  if not self.active then return end

  self.in_battle = false
  self:activate()
end

function Scene:update()
  if self.in_battle or self.fading then return end

  local player = self.player_character

  for _, exit in ipairs(self.exits) do
    if exit:intersect(player:bounds()) and exit.layer == player:get_layer() then
      EventManager.trigger("scene_exit", exit.dest_scene, exit.dest_entrance)
      return
    end
  end

  player:update(self.blocks)
  for i = #self.objects, 1, -1 do
    local object = self.objects[i]
    object:update(player)
    if object.destroyed then
      table.remove(self.objects, i)
    end
  end
end

function Scene:draw()
  self.map:foreach(function(i, j, x, y)
    local tile_index = self.tiles[i + 1][j + 1]
    if tile_index > 0 then
      self.tileset[tile_index]:draw(x, y)
    end
    if (i + j) % 2 == 0 then
      Window.draw_polygon(UI_Z_INDEX, {0, 0, 0, 0.2}, "fill", x + HALF_TILE_WIDTH, y, x + TILE_WIDTH, y + HALF_TILE_HEIGHT, x + HALF_TILE_WIDTH, y + TILE_HEIGHT, x, y + HALF_TILE_HEIGHT)
    end
  end)

  for _, block in ipairs(self.blocks) do
    block:draw(self.map)
  end

  if not self.in_battle then
    for _, object in ipairs(self.objects) do
      object:draw(self.map)
    end
    self.player_character:draw(self.map)
  end

  Window.draw_rectangle(0, 0, UI_Z_INDEX - 1, SCREEN_WIDTH, SCENE_CAMERA_OFFSET, {0, 0, 0})
  Window.draw_rectangle(0, SCREEN_HEIGHT - SCENE_CAMERA_OFFSET, UI_Z_INDEX - 1, SCREEN_WIDTH, SCENE_CAMERA_OFFSET, {0, 0, 0})
end
