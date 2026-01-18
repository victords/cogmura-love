require("src.scene_parser")

Scene = {}
Scene.__index = Scene

local function draw_tile(color, x, y)
  Window.draw_polygon(1, color, "fill", x + HALF_TILE_WIDTH, y, x + TILE_WIDTH, y + HALF_TILE_HEIGHT, x + HALF_TILE_WIDTH, y + TILE_HEIGHT, x, y + HALF_TILE_HEIGHT)
end

function Scene.new()
  local self = setmetatable({}, Scene)
  self.index = 1

  self.map = Map.new(TILE_WIDTH, TILE_HEIGHT, SCENE_TILE_COUNT, SCENE_TILE_COUNT, Window.reference_width, Window.reference_height, true, false)
  self.map:set_camera(SCENE_TILE_COUNT / 4 * TILE_WIDTH, SCENE_TILE_COUNT / 4 * TILE_HEIGHT - SCENE_CAMERA_OFFSET)
  self.blocks = {}
  self.objects = {}
  self.tiles = {}
  SceneParser.new(self):parse()

  EventManager.listen("player_move_start", Scene.prepare_obstacles, self)
  EventManager.listen("battle_start", Scene.on_battle_start, self)
  EventManager.listen("battle_finish", Scene.on_battle_finish, self)

  return self
end

function Scene:prepare_obstacles(player_z, player_height)
  for _, block in ipairs(self.blocks) do
    block:set_body_active(block.top > player_z + STEP_THRESHOLD and player_z + player_height > block.z)
  end
end

function Scene:on_battle_start()
  self.in_battle = true
  self.player_character:deactivate()
  for _, object in ipairs(self.objects) do
    object:deactivate()
  end
  for _, block in ipairs(self.blocks) do
    block:set_body_active(false)
  end
end

function Scene:on_battle_finish()
  self.in_battle = false
  self.player_character:activate()
  for _, object in ipairs(self.objects) do
    object:activate()
  end
  for _, block in ipairs(self.blocks) do
    block:set_body_active(true)
  end
end

function Scene:update()
  if self.in_battle then return end

  self.player_character:update(self.blocks)
  for i = #self.objects, 1, -1 do
    local object = self.objects[i]
    object:update(self.player_character)
    if object.destroyed then
      table.remove(self.objects, i)
    end
  end
end

function Scene:draw()
  self.map:foreach(function(i, j, x, y)
    local color = (i + j) % 2 == 0 and {0.15, 0.6, 0} or {0.3, 0.8, 0}
    draw_tile(color, x, y)
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
