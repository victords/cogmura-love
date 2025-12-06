PlayerCharacter = setmetatable({}, GameObject)
PlayerCharacter.__index = PlayerCharacter

BASE_SPEED = 3 * PHYSICS_UNIT -- move 3 tiles per second
DIAGONAL_SPEED = BASE_SPEED * math.sqrt(2) * 0.5
JUMP_SPEED = 10 -- per frame

function PlayerCharacter.new(col, row, layer)
  local self = GameObject.new((col + 0.5) * PHYSICS_UNIT - 6, (row + 0.5) * PHYSICS_UNIT - 6, 12, 12, "sprite/player", nil, nil, nil, {shape = "circle"})
  setmetatable(self, PlayerCharacter)
  self.z = layer * PHYSICS_UNIT
  self.height = PHYSICS_UNIT
  self.speed_z = 0
  self.inner_size = self.w * math.sqrt(2) * 0.5
  self.inner_offset = (self.w - self.inner_size) * 0.5
  return self
end

function PlayerCharacter:inner_bounds()
  return Rectangle.new(self:get_x() + self.inner_offset, self:get_y() + self.inner_offset, self.inner_size, self.inner_size)
end

function PlayerCharacter:update(blocks)
  local speed = Vector.new()
  local up = KB.down("up")
  local rt = KB.down("right")
  local dn = KB.down("down")
  local lf = KB.down("left")

  if up then
    if rt then speed.x = 0; speed.y = -BASE_SPEED
    elseif lf then speed.x = -BASE_SPEED; speed.y = 0
    else speed.x = -DIAGONAL_SPEED; speed.y = -DIAGONAL_SPEED
    end
  elseif dn then
    if rt then speed.x = BASE_SPEED; speed.y = 0
    elseif lf then speed.x = 0; speed.y = BASE_SPEED
    else speed.x = DIAGONAL_SPEED; speed.y = DIAGONAL_SPEED
    end
  elseif rt then speed.x = DIAGONAL_SPEED; speed.y = -DIAGONAL_SPEED
  elseif lf then speed.x = -DIAGONAL_SPEED; speed.y = DIAGONAL_SPEED
  end

  EventManager.trigger("player_move_start", self.z, self.height)
  self:move(speed, nil, nil, true)
  self:move_z(blocks)
end

function PlayerCharacter:draw(map)
  local x = self:get_x() + self.w / 2
  local y = self:get_y() + self.h / 2
  local col = math.floor(x / PHYSICS_UNIT)
  local row = math.floor(y / PHYSICS_UNIT)
  local offset_x = x - col * PHYSICS_UNIT
  local offset_y = y - row * PHYSICS_UNIT
  local base_pos = map:get_screen_pos(col, row)
  local screen_x = base_pos.x + HALF_TILE_WIDTH * (1 + (offset_x / PHYSICS_UNIT) - (offset_y / PHYSICS_UNIT))
  local screen_y = base_pos.y + HALF_TILE_HEIGHT * ((offset_x / PHYSICS_UNIT) + (offset_y / PHYSICS_UNIT))
  self.img:draw(Utils.round(screen_x - self.img.width / 2), Utils.round(screen_y - ISO_UNIT - 8) - (self.z / PHYSICS_UNIT) * ISO_UNIT, (col + row + 2) * HALF_TILE_HEIGHT * 100)
end

-- private

function PlayerCharacter:move_z(blocks)
  local bounds = self:inner_bounds()
  local layer = math.floor(self.z / PHYSICS_UNIT)
  local floors = Utils.select(blocks, function(block)
    return block.layer + block.height == layer and block:bounds():intersect(bounds)
  end)
  local ceilings = Utils.select(blocks, function(block)
    return block.z >= self.z + self.height and block:bounds():intersect(bounds)
  end)

  local floor = nil
  local ceiling = nil
  local max = -1
  local min = 1000000
  for _, f in ipairs(floors) do
    if f.col + f.row + f.cols + f.rows > max then
      max = f.col + f.row + f.cols + f.rows
      floor = f
    end
  end
  for _, c in ipairs(ceilings) do
    if c.z < min then
      min = c.z
      ceiling = c
    end
  end

  floor = floor or layer == 0
  local floor_z = layer * PHYSICS_UNIT
  local grounded = floor and self.z == floor_z
  if grounded then
    if KB.pressed("space") then self.speed_z = JUMP_SPEED end
  else
    self.speed_z = self.speed_z - GRAVITY
  end

  if floor and self.speed_z < 0 and self.z + self.speed_z < floor_z then
    self.z = floor_z
    self.speed_z = 0
  elseif ceiling and self.speed_z > 0 and self.z + self.height + self.speed_z > ceiling.z then
    self.z = ceiling.z - self.height
    self.speed_z = 0
  else
    self.z = self.z + self.speed_z
  end
end
