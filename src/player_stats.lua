require("src.stats")

PlayerStats = setmetatable({}, Stats)
PlayerStats.__index = PlayerStats

function PlayerStats.load(values)
  local self = Stats.new(unpack(Utils.map(Utils.split(values, ","), function(s) return tonumber(s) end)))
  setmetatable(self, PlayerStats)

  self.inventory = {}
  EventManager.listen("item_pick_up", PlayerStats.add_item, self)

  return self
end

function PlayerStats:add_item(item_id)
  if self.inventory[item_id] == nil then
    self.inventory[item_id] = 0
  end
  self.inventory[item_id] = self.inventory[item_id] + 1
end
