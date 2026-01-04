require("src.stats")

PlayerStats = setmetatable({}, Stats)
PlayerStats.__index = PlayerStats

function PlayerStats.load(values)
  local self = Stats.new(unpack(Utils.map(Utils.split(values, ","), function(s) return tonumber(s) end)))
  setmetatable(self, PlayerStats)
  return self
end
