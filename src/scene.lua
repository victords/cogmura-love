require("src.constants")
require("src.iso_block")
require("src.player_character")
require("src.enemy")
require("src.item")

Scene = {}
Scene.__index = Scene

local function draw_tile(color, x, y)
  Window.draw_polygon(1, color, "fill", x + HALF_TILE_WIDTH, y, x + TILE_WIDTH, y + HALF_TILE_HEIGHT, x + HALF_TILE_WIDTH, y + TILE_HEIGHT, x, y + HALF_TILE_HEIGHT)
end

function Scene.new()
  local self = setmetatable({}, Scene)
  self.index = 1

  self.map = Map.new(TILE_WIDTH, TILE_HEIGHT, 20, 20, Window.reference_width, Window.reference_height, true, false)
  self.blocks = {
    IsoBlock.new(6, 2, 0, 1, 1, 4, false, {1, 0, 0}),
    IsoBlock.new(1, 3, 0, 7, 1, 1, false, {0, 1, 0}),
    IsoBlock.new(4, 6, 0, 1, 1, 4, false, {0, 0, 1}),
    IsoBlock.new(9, 9, 0, 2, 2, 2, false, "sprite/block2"),
    IsoBlock.new(10, 5, 0, 1, 1, 0.25),
    IsoBlock.new(10, 4, 0, 1, 1, 0.5),
    IsoBlock.new(10, 3, 0, 1, 1, 0.75),
    IsoBlock.new(10, 2, 0, 1, 1, 1),
    IsoBlock.new(2, 13, 0, 3, 4, 2, true, "sprite/block1", Vector.new(-10, -10)),
    IsoBlock.new(12, 7, 0, 5, 2, 1, true),
  }
  self.objects = {
    Enemy.new(1, 13, 15, 0),
    Enemy.new(1, 13, 16, 0),
    Item.new(1, 7, 5, 0),
  }
  self.player_character = PlayerCharacter.new(5, 5, 0)
  self.battle_spawn_points = {{3, 16}, {12, 12}, {16, 12}}

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
  for _, object in ipairs(self.objects) do
    object:update(self.player_character)
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
end
