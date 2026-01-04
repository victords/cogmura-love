require("src/iso_game_object")

PlayerCharacter = setmetatable({}, IsoGameObject)
PlayerCharacter.__index = PlayerCharacter

BASE_SPEED = 5 * PHYSICS_UNIT -- move 3 tiles per second
DIAGONAL_SPEED = BASE_SPEED * math.sqrt(2) * 0.5
JUMP_SPEED = 10 -- per frame

function PlayerCharacter.new(col, row, layer)
  local self = IsoGameObject.new(col, row, layer, 12, 12, PHYSICS_UNIT, "sprite/player", Vector.new(0, -8), nil, nil, {shape = "circle"})
  setmetatable(self, PlayerCharacter)
  self.speed_z = 0
  self.inner_size = self.w * math.sqrt(2) * 0.5
  self.inner_offset = (self.w - self.inner_size) * 0.5

  return self
end

function PlayerCharacter:activate()
  self.body:setActive(true)
end

function PlayerCharacter:deactivate()
  self.body:setLinearVelocity(0, 0)
  self.body:setActive(false)
  self.speed_z = 0
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

  self.z_index = nil
  EventManager.trigger("player_move_start", self.z, self.height)
  self:move(speed, nil, nil, true)
  self:move_z(blocks)
end

-- private

function PlayerCharacter:move_z(blocks)
  local bounds = self:inner_bounds()
  local intersecting_blocks = Utils.select(blocks, function(block)
    return block:intersect(bounds)
  end)
  local floors = Utils.select(intersecting_blocks, function(block)
    return block.top <= self.z
  end)
  local ceilings = Utils.select(intersecting_blocks, function(block)
    return block.z >= self.z + self.height
  end)

  local floor = nil
  local ceiling = nil
  local max = -1
  local max_z_index = -1
  local min = 1000000
  for _, f in ipairs(floors) do
    local z_index = f.col + f.row + f.cols + f.rows
    if f.top > max then
      max = f.top
      max_z_index = z_index
      floor = f
    elseif f.top == max and z_index > max_z_index then
      max_z_index = z_index
      floor = f
    end
  end
  for _, c in ipairs(ceilings) do
    if c.z < min then
      min = c.z
      ceiling = c
    end
  end

  local grounded = self.z == 0 or (floor and self.z == floor.top)
  if grounded then
    if KB.pressed("space") then self.speed_z = JUMP_SPEED end
  else
    self.speed_z = self.speed_z - GRAVITY
  end

  if floor == nil and self.speed_z < 0 and self.z + self.speed_z < 0 then
    self.z = 0
    self.speed_z = 0
  elseif floor and self.speed_z < 0 and self.z + self.speed_z < floor.top then
    self.z = floor.top
    self.speed_z = 0
  elseif ceiling and self.speed_z > 0 and self.z + self.height + self.speed_z > ceiling.z then
    self.z = ceiling.z - self.height
    self.speed_z = 0
  else
    self.z = self.z + self.speed_z
  end

  for _, block in ipairs(intersecting_blocks) do
    if block.top > self.z and block.top <= self.z + STEP_THRESHOLD then
      self.z = block.top
      floor = block
      break
    end
  end

  if floor and floor.max_z_index then
    self.z_index = floor.max_z_index
  end
end
