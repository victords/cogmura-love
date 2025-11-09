PlayerCharacter = setmetatable({}, GameObject)
PlayerCharacter.__index = PlayerCharacter

function PlayerCharacter.new(col, row)
  local self = GameObject.new((col + 0.5) * PHYSICS_UNIT - 6, (row + 0.5) * PHYSICS_UNIT - 6, 12, 12, nil, nil, nil, nil, {shape = "circle"})
  setmetatable(self, PlayerCharacter)
  return self
end

function PlayerCharacter:update()
  local speed = Vector.new()
  local up = KB.down("up")
  local rt = KB.down("right")
  local dn = KB.down("down")
  local lf = KB.down("left")

  if up then
    if rt then speed.x = 0; speed.y = -50
    elseif lf then speed.x = -50; speed.y = 0
    else speed.x = -35; speed.y = -35
    end
  elseif dn then
    if rt then speed.x = 50; speed.y = 0
    elseif lf then speed.x = 0; speed.y = 50
    else speed.x = 35; speed.y = 35
    end
  elseif rt then speed.x = 35; speed.y = -35
  elseif lf then speed.x = -35; speed.y = 35
  end

  self:move(speed, nil, nil, true)
end

function PlayerCharacter:draw(map)
  local x = self:get_x()
  local y = self:get_y()
  local col = math.floor(x / PHYSICS_UNIT)
  local row = math.floor(y / PHYSICS_UNIT)
  local offset_x = x - col * PHYSICS_UNIT
  local offset_y = y - row * PHYSICS_UNIT
  local base_pos = map:get_screen_pos(col, row)
  local screen_x = base_pos.x + HALF_TILE_WIDTH * (1 + (offset_x / PHYSICS_UNIT) - (offset_y / PHYSICS_UNIT))
  local screen_y = base_pos.y + HALF_TILE_HEIGHT * ((offset_x / PHYSICS_UNIT) + (offset_y / PHYSICS_UNIT))
  Window.draw_circle(screen_x, screen_y, screen_y * 100, 16, {0.3, 0.3, 1})
end
