require("src.iso_game_object")

BattlePlayer = setmetatable({}, IsoGameObject)
BattlePlayer.__index = BattlePlayer

function BattlePlayer.new(col, row, layer)
  local self = IsoGameObject.new(col, row, layer, 12, 12, PHYSICS_UNIT, "sprite/player", Vector.new(0, -8))
  return self
end
