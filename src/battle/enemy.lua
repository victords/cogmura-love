require("src.iso_game_object")

BattleEnemy = setmetatable({}, IsoGameObject)
BattleEnemy.__index = BattleEnemy

function BattleEnemy.new(id, col, row, layer, map)
  local data = EnemyCache.fetch(id)

  local self = IsoGameObject.new(col, row, layer, data.size, data.size, ENEMY_HEIGHT, data.img_or_path, data.img_gap)
  local screen_pos = map:get_screen_pos(col, row) + Vector.new(HALF_TILE_WIDTH, HALF_TILE_HEIGHT - layer * ISO_UNIT)
  self.screen_x = screen_pos.x
  self.screen_y = screen_pos.y
  self.body:setActive(false)
  return self
end
