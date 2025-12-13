require("src.constants")
require("src.iso_block")
require("src.player_character")
require("src.enemy")

Scene = {}
Scene.__index = Scene

local function draw_tile(color, x, y)
  Window.draw_polygon(1, color, "fill", x + HALF_TILE_WIDTH, y, x + TILE_WIDTH, y + HALF_TILE_HEIGHT, x + HALF_TILE_WIDTH, y + TILE_HEIGHT, x, y + HALF_TILE_HEIGHT)
end

function Scene.new()
  local self = setmetatable({}, Scene)

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
    Enemy.new("1", 13, 15, 0),
    Enemy.new("1", 13, 16, 0),
  }
  for _, obj in ipairs(self.objects) do
    obj.body:setActive(false)
  end
  self.player_character = PlayerCharacter.new(5, 5, 0)

  EventManager.listen("player_move_start", Scene.prepare_obstacles, self)

  return self
end

function Scene:prepare_obstacles(player_z, player_height)
  for _, block in ipairs(self.blocks) do
    block:setBodyActive(block.top > player_z + STEP_THRESHOLD and player_z + player_height > block.z)
  end
end

function Scene:update()
  self.player_character:update(self.blocks)
end

function Scene:draw()
  self.map:foreach(function(i, j, x, y)
    local color = (i + j) % 2 == 0 and {0.15, 0.6, 0} or {0.3, 0.8, 0}
    draw_tile(color, x, y)
  end)

  for _, block in ipairs(self.blocks) do
    block:draw(self.map)
  end
  for _, object in ipairs(self.objects) do
    object:draw(self.map)
  end
  self.player_character:draw(self.map)
end
