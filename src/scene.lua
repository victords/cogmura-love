require("src.constants")
require("src.iso_block")
require("src.player_character")

Scene = {}
Scene.__index = Scene

local function draw_tile(color, x, y)
  if color then love.graphics.setColor(color) end
  love.graphics.polygon("fill", x + HALF_TILE_WIDTH, y, x + TILE_WIDTH, y + HALF_TILE_HEIGHT, x + HALF_TILE_WIDTH, y + TILE_HEIGHT, x, y + HALF_TILE_HEIGHT)
end

local function new_ramp(i, j, left, inverted)
  local ramp = Ramp.new(i * PHYSICS_UNIT, j * PHYSICS_UNIT, PHYSICS_UNIT, PHYSICS_UNIT, left, inverted)
  ramp.col = i
  ramp.row = j
  return ramp
end

function Scene.new()
  local self = setmetatable({}, Scene)

  self.map = Map.new(TILE_WIDTH, TILE_HEIGHT, 20, 20, Window.reference_width, Window.reference_height, true, false)
  self.blocks = {
    IsoBlock.new(2, 0, 0, 1, 1, 1),
    IsoBlock.new(1, 0, 0, 1, 1, 1),
    IsoBlock.new(0, 0, 0, 1, 1, 1),
    IsoBlock.new(0, 1, 0, 1, 1, 1),
    IsoBlock.new(3, 3, 0, 1, 1, 4),
    IsoBlock.new(10, 3, 2, 1, 1, 1),
    IsoBlock.new(3, 10, 0, 3, 2, 1),
    IsoBlock.new(15, 5, 1, 2, 5, 4)
  }
  self.ramps = {
    new_ramp(1, 1, false, true),
    new_ramp(0, 8, false, false),
    new_ramp(8, 8, true, false)
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

  love.graphics.setColor(1, 0.3, 0.3)
  for _, ramp in ipairs(self.ramps) do
    local pos = self.map:get_screen_pos(ramp.col, ramp.row)
    local points = {}
    if ramp.left or ramp.inverted then
      table.insert(points, pos.x + TILE_WIDTH)
      table.insert(points, pos.y + HALF_TILE_HEIGHT)
    end
    if ramp.left or not ramp.inverted then
      table.insert(points, pos.x + HALF_TILE_WIDTH)
      table.insert(points, pos.y + TILE_HEIGHT)
    end
    if not ramp.left or ramp.inverted then
      table.insert(points, pos.x + HALF_TILE_WIDTH)
      table.insert(points, pos.y)
    end
    if not ramp.left or not ramp.inverted then
      table.insert(points, pos.x)
      table.insert(points, pos.y + HALF_TILE_HEIGHT)
    end
    love.graphics.polygon("fill", unpack(points))
  end

  for _, block in ipairs(self.blocks) do
    block:draw(self.map)
  end
  self.player_character:draw(self.map)
end
