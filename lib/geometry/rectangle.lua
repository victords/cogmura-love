Rectangle = {}
Rectangle.__index = Rectangle

function Rectangle.new(x, y, w, h)
  local self = setmetatable({}, Rectangle)
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  return self
end

function Rectangle:intersect(other)
  return self.x + self.w > other.x and
    other.x + other.w > self.x and
    self.y + self.h > other.y and
    other.y + other.h > self.y
end
