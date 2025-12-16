BattleUi = {}
BattleUi.__index = BattleUi

function BattleUi.new(player_stats)
  local self = setmetatable({}, BattleUi)
  self.player_stats = player_stats
  self.font = Res.font("font", 24)
  return self
end

function BattleUi:update()
end

function BattleUi:draw()
  Window.draw_rectangle(200, 200, UI_Z_INDEX, 200, 200, {0.75, 0.75, 0.75})
end
