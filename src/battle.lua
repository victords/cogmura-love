require("src.battle.player")
require("src.battle.enemy")

Battle = {}
Battle.__index = Battle

function Battle.new(map, spawn_points, initiator)
  local self = setmetatable({}, Battle)
  self.map = map
  self.enemies = {}
  for index, spawn_point in ipairs(spawn_points) do
    if index == 1 then
      self.player = BattlePlayer.new(spawn_point[1], spawn_point[2], spawn_point[3] or 0, map)
    else
      table.insert(self.enemies, BattleEnemy.new(initiator.id, spawn_point[1], spawn_point[2], spawn_point[3] or 0, map))
    end
  end
  self.flee_probability = 0.99

  return self
end

function Battle:on_action_start(action, ...)
  local args = {...}
  if action == "attack" then
    self.player:start_animation("attack")
    self.player:move_towards(self.enemies[args[1]])
  elseif action == "flee" then
    if math.random() < self.flee_probability then
      EventManager.trigger("battle_finish", "flee")
    else
      self:start_enemy_turn()
    end
  end
end

function Battle:start_enemy_turn()
  print("---- enemy turn")
end

function Battle:update()

end

function Battle:draw()
  self.player:draw(self.map)
  for _, enemy in ipairs(self.enemies) do
    enemy:draw(self.map)
  end
end
