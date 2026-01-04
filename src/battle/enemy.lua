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

function BattleEnemy:update()
  if not self.active then return end

  if self.state == "idle" then
    local action = {type = "attack", value = self.stats.str}
    local targets = self.on_action_select(action)
    action.target = targets[1]
    local target_pos = targets[1]:get_mass_center() + Vector.new(PHYSICS_UNIT, -PHYSICS_UNIT)
    self:set_moving_towards(target_pos, function()
      self.on_action_perform(action)
      self:set_moving_to_start()
    end)
  elseif self.state == "moving" then
    self:move_towards_target()
  end
end
