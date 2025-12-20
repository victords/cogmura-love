require("src.iso_game_object")

BattlePlayer = setmetatable({}, IsoGameObject)
BattlePlayer.__index = BattlePlayer

function BattlePlayer.new(col, row, layer, map)
  local self = IsoGameObject.new(col, row, layer, 12, 12, PHYSICS_UNIT, "sprite/player", Vector.new(0, -8))
  local screen_pos = map:get_screen_pos(col, row) + Vector.new(HALF_TILE_WIDTH, HALF_TILE_HEIGHT - layer * ISO_UNIT)
  self.screen_x = screen_pos.x
  self.screen_y = screen_pos.y
  self.body:setActive(false)
  return self
end
