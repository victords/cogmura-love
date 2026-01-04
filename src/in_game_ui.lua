InGameUi = {}
InGameUi.__index = InGameUi

function InGameUi.new(player_stats)
  local self = setmetatable({}, InGameUi)
  self.font = Res.font("font", 24)
  self.max_hp = player_stats.max_hp
  self:update_hp_text(player_stats.hp)
  player_stats.on_hp_change:listen(function(old_value, new_value)
    self:update_hp_text(new_value)
  end)
  return self
end

function InGameUi:update_hp_text(new_value)
  self.hp_text = tostring(new_value) .. "/" .. tostring(self.max_hp)
end

function InGameUi:update()
end

function InGameUi:draw()
  self.font:draw_text(self.hp_text, 10, 10)
end
