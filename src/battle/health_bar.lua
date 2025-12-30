HealthBar = {}
HealthBar.__index = HealthBar

function HealthBar.new(stats, object)
  local self = setmetatable({}, HealthBar)
  self.stats = stats
  self.bar = ProgressBar.new(object.screen_x - 40, object.screen_y + 20, {w = 80, h = 10, bg_color = {1, 0, 0}, fg_color = {0, 1, 0}, max_value = stats.max_hp, value = stats.hp})
  return self
end

--function HealthBar:on_hp_change(new_value)
--  self.bar:set_value(new_value)
--end

function HealthBar:draw()
  self.bar:draw({1, 1, 1}, UI_Z_INDEX)
end
