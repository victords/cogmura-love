require("src.event")

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

  self.on_hp_change = Event.new()

  return self
end

function Stats:take_damage(amount)
  amount = amount - self.def
  self:set_hp(self.hp - amount)
end

function Stats:heal(amount)
  self:set_hp(self.hp + amount)
end

function Stats:set_hp(value)
  local prev_value = self.hp
  if value < 0 then
    self.hp = 0
  elseif value > self.max_hp then
    self.hp = self.max_hp
  else
    self.hp = value
  end
  self.on_hp_change:trigger(prev_value, self.hp)
end
