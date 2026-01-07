require("src.battle.player")
require("src.battle.enemy")

Battle = {}
Battle.__index = Battle

function Battle.new(player_stats, map, spawn_points, initiator)
  local self = setmetatable({}, Battle)
  self.map = map
  self.combatants = {}
  self.enemies = {}
  for index, spawn_point in ipairs(spawn_points) do
    local combatant = index == 1 and
      BattlePlayer.new(player_stats, spawn_point[1], spawn_point[2], spawn_point[3] or 0, map) or
      BattleEnemy.new(initiator.id, spawn_point[1], spawn_point[2], spawn_point[3] or 0, map)
    table.insert(self.combatants, combatant)
    if index == 1 then
      self.player = combatant
      combatant.stats.on_hp_change:listen(function (old_value, new_value)
        if new_value == 0 then
          EventManager.trigger("battle_finish", "defeat")
        end
      end)
    else
      table.insert(self.enemies, combatant)
      combatant.stats.on_hp_change:listen(function(old_value, new_value)
        if new_value == 0 then
          self:on_enemy_defeat(combatant)
        end
      end)
    end
    combatant.on_action_select = function(action) return self:get_available_targets(action) end
    combatant.on_action_perform = function(action) self:resolve_action(action) end
    combatant.on_action_finish = function() self:set_next_combatant() end
  end
  self.flee_probability = 0.99
  self.combatant_index = 0
  self:set_next_combatant()

  return self
end

function Battle:set_next_combatant()
  self.combatant_index = self.combatant_index + 1
  if self.combatant_index > #self.combatants then self.combatant_index = 1 end
  self.active_combatant = self.combatants[self.combatant_index]
  self.active_combatant:start_turn()
end

function Battle:on_enemy_defeat(enemy)
  Utils.remove(self.combatants, enemy)
  Utils.remove(self.enemies, enemy)

  if #self.enemies == 0 then
    EventManager.trigger("battle_finish", "victory")
  end
end

function Battle:get_available_targets(action)
  if action.type == "attack" then
    if self.active_combatant.is_player then
      return self.enemies
    else
      return {self.player}
    end
  elseif action.type == "flee" then
    return nil
  end
end

function Battle:resolve_action(action)
  if action.type == "attack" then
    action.target.stats:take_damage(action.value)
  elseif action.type == "flee" then
    if math.random() < self.flee_probability then
      EventManager.trigger("battle_finish", "flee")
    end
  end
end

function Battle:update()
  for _, combatant in ipairs(self.combatants) do
    combatant:update()
  end
end

function Battle:draw()
  for _, combatant in ipairs(self.combatants) do
    combatant:draw(self.map)
  end
end
