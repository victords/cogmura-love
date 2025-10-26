require("src.stats")

PlayerStats = setmetatable({}, Stats)
PlayerStats.__index = PlayerStats

function PlayerStats.load(values)
  local self = Stats.new(unpack(Utils.split(values, ",")))
  setmetatable(self, PlayerStats)
  return self
end
