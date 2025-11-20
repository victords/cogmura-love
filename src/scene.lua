require("src.constants")
require("src.iso_block")
require("src.player_character")

Scene = {}
Scene.__index = Scene

local function draw_tile(color, x, y)
  if color then love.graphics.setColor(color) end
  love.graphics.polygon("fill", x + HALF_TILE_WIDTH, y, x + TILE_WIDTH, y + HALF_TILE_HEIGHT, x + HALF_TILE_WIDTH, y + TILE_HEIGHT, x, y + HALF_TILE_HEIGHT)
end

function Scene.new()
  local self = setmetatable({}, Scene)

  self.map = Map.new(TILE_WIDTH, TILE_HEIGHT, 20, 20, Window.reference_width, Window.reference_height, true, false)
  self.blocks = {
    IsoBlock.new(6, 2, 0, 1, 1, 4, {1, 0, 0}),
    IsoBlock.new(1, 3, 0, 7, 1, 1, {0, 1, 0}),
    IsoBlock.new(4, 6, 0, 1, 1, 4, {0, 0, 1}),
  }
  self.player_character = PlayerCharacter.new(5, 5, 0)

  EventManager.listen("player_move_start", Scene.prepare_obstacles, self)

  return self
end

function Scene:prepare_obstacles(layer)
  for _, block in ipairs(self.blocks) do
    block.body:setActive(block.layer == layer)
  end
end

function Scene:update()
  self.player_character:update()
end

function Scene:draw()
  self.map:foreach(function(i, j, x, y)
    local color = (i + j) % 2 == 0 and {0.15, 0.6, 0} or {0.3, 0.8, 0}
    draw_tile(color, x, y)
  end)

  for _, block in ipairs(self.blocks) do
    block:draw(self.map)
  end
  self.player_character:draw(self.map)
end
