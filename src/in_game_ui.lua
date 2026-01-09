require("src.cache.item")

InGameUi = {}
InGameUi.__index = InGameUi

function InGameUi.new(player_stats)
  local self = setmetatable({}, InGameUi)
  self.player_stats = player_stats
  self.font = Res.font("font", 24)
  return self
end

function InGameUi:update() end

function InGameUi:draw()
  self.font:draw_text(tostring(self.player_stats.hp) .. "/" .. tostring(self.player_stats.max_hp), 10, 10)
  for k, v in pairs(self.player_stats.inventory) do
    local item_name = ItemCache.name_map[k]
    self.font:draw_text(item_name .. ":" .. tostring(v), 10, 30)
  end
end
