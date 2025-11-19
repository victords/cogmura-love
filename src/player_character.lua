PlayerCharacter = setmetatable({}, GameObject)
PlayerCharacter.__index = PlayerCharacter

BASE_SPEED = 3 * PHYSICS_UNIT -- move 3 tiles per second
DIAGONAL_SPEED = BASE_SPEED * math.sqrt(2) * 0.5

function PlayerCharacter.new(col, row, layer)
  local self = GameObject.new((col + 0.5) * PHYSICS_UNIT - 6, (row + 0.5) * PHYSICS_UNIT - 6, 12, 12, "sprite/player", nil, nil, nil, {shape = "circle"})
  setmetatable(self, PlayerCharacter)
  self.z = layer * PHYSICS_UNIT
  self.height = PHYSICS_UNIT
  return self
end

function PlayerCharacter:update()
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

  local layer = math.floor(self.z / PHYSICS_UNIT)
  EventManager.trigger("player_move_start", layer)
  self:move(speed, nil, nil, true)

  -- TODO z-axis movement
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
  self.img:draw(Utils.round(screen_x - self.img.width / 2), Utils.round(screen_y - ISO_UNIT - 8), (col + row + 2) * HALF_TILE_HEIGHT * 100)
end
