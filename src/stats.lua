Stats = {}
Stats.__index = Stats

function Stats.new(max_hp, max_mp, str, def, exp, money, hp, mp)
  local self = setmetatable({}, Stats)
  self.max_hp = max_hp
  self.hp = hp or max_hp
  self.max_mp = max_mp
  self.mp = mp or max_mp
  self.str = str
  self.def = def
  self.exp = exp
  self.money = money
  return self
end
