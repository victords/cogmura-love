require("src.iso_game_object")

BattleEnemy = setmetatable({}, IsoGameObject)
BattleEnemy.__index = BattleEnemy

function BattleEnemy.new(id, col, row, layer, map)
  local data = EnemyCache.fetch(id)

  local self = IsoGameObject.new(col, row, layer, data.size, data.size, ENEMY_HEIGHT, data.img_or_path, data.img_gap)
  setmetatable(self, BattleEnemy)
  local screen_pos = map:get_screen_pos(col, row) + Vector.new(HALF_TILE_WIDTH, HALF_TILE_HEIGHT - layer * ISO_UNIT)
  self.stats = Stats.new(data.max_hp, data.max_mp, data.str, data.def, data.exp, data.money)
  self.screen_x = screen_pos.x
  self.screen_y = screen_pos.y
  self.health_bar = HealthBar.new(self.stats, self)

  self.body:setActive(false)
  return self
end

function BattleEnemy:draw(map)
  IsoGameObject.draw(self, map)
  self.health_bar:draw()
end
