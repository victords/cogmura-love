require("src.battle.combatant")

BattlePlayer = setmetatable({}, Combatant)
BattlePlayer.__index = BattlePlayer

function BattlePlayer.new(stats, col, row, layer, map)
  local self = Combatant.new(stats, col, row, layer, 12, 12, PHYSICS_UNIT, "sprite/player", Vector.new(0, -8), map)
  setmetatable(self, BattlePlayer)
  return self
end
