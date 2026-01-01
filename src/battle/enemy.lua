require("src.battle.combatant")

BattleEnemy = setmetatable({}, Combatant)
BattleEnemy.__index = BattleEnemy

function BattleEnemy.new(id, col, row, layer, map)
  local data = EnemyCache.fetch(id)
  local stats = Stats.new(data.max_hp, data.max_mp, data.str, data.def, data.exp, data.money)
  local self = Combatant.new(stats, col, row, layer, data.size, data.size, ENEMY_HEIGHT, data.img_or_path, data.img_gap, map)
  setmetatable(self, BattleEnemy)
  return self
end

function BattleEnemy:draw(map)
  IsoGameObject.draw(self, map)
  self.health_bar:draw()
end
