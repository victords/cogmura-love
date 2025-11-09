require("src.constants")
require("src.player_character")

Scene = {}
Scene.__index = Scene

local function draw_tile(color, x, y)
  if color then love.graphics.setColor(color) end
  love.graphics.polygon("fill", x + 48, y, x + 96, y + 24, x + 48, y + 48, x, y + 24)
end

local function new_block(i, j)
  local block = Block.new(i * PHYSICS_UNIT, j * PHYSICS_UNIT, PHYSICS_UNIT, PHYSICS_UNIT)
  block.col = i
  block.row = j
  return block
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
    new_block(0, 0),
    new_block(1, 0),
    new_block(2, 0),
    new_block(0, 1),
    new_block(3, 3),
  }
  self.ramps = {
    new_ramp(1, 1, false, true),
    new_ramp(0, 8, false, false),
    new_ramp(8, 8, true, false)
  }
  self.player_character = PlayerCharacter.new(5, 5)

  return self
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
  for _, block in ipairs(self.blocks) do
    local pos = self.map:get_screen_pos(block.col, block.row)
    draw_tile(nil, pos.x, pos.y)
  end
  for _, ramp in ipairs(self.ramps) do
    local pos = self.map:get_screen_pos(ramp.col, ramp.row)
    local points = {}
    if ramp.left or ramp.inverted then
      table.insert(points, pos.x + 96)
      table.insert(points, pos.y + 24)
    end
    if ramp.left or not ramp.inverted then
      table.insert(points, pos.x + 48)
      table.insert(points, pos.y + 48)
    end
    if not ramp.left or ramp.inverted then
      table.insert(points, pos.x + 48)
      table.insert(points, pos.y)
    end
    if not ramp.left or not ramp.inverted then
      table.insert(points, pos.x)
      table.insert(points, pos.y + 24)
    end
    love.graphics.polygon("fill", unpack(points))
  end

  self.player_character:draw(self.map)
end
