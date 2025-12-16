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
      self.player = BattlePlayer.new(spawn_point[1], spawn_point[2], spawn_point[3] or 0)
    else
      table.insert(self.enemies, BattleEnemy.new(initiator.id, spawn_point[1], spawn_point[2], spawn_point[3] or 0))
    end
  end

  return self
end

function Battle:update() end

function Battle:draw()
  self.player:draw(self.map)
  for _, enemy in ipairs(self.enemies) do
    enemy:draw(self.map)
  end
end
