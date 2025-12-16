require("src.iso_game_object")

BattleEnemy = setmetatable({}, IsoGameObject)
BattleEnemy.__index = BattleEnemy

function BattleEnemy.new(id, col, row, layer)
  local data = EnemyCache.fetch(id)

  local self = IsoGameObject.new(col, row, layer, data.size, data.size, ENEMY_HEIGHT, data.img_or_path, data.img_gap)
  return self
end
