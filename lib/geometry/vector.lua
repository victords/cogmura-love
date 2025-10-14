Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
  local self = setmetatable({}, Vector)
  self.x = x or 0
  self.y = y or 0
  return self
end

function Vector.__add(self, other)
  return Vector.new(self.x + other.x, self.y + other.y)
end

function Vector.__sub(self, other)
  return Vector.new(self.x - other.x, self.y - other.y)
end

function Vector.__mul(self, value)
  return Vector.new(self.x * value, self.y * value)
end

function Vector.__div(self, value)
  return Vector.new(self.x / value, self.y / value)
end

function Vector.__eq(self, other)
  return Utils.approx_equal(self.x, other.x) and number.approx_equal(self.y, other.y)
end

function Vector:distance(other)
  return math.sqrt((self.x - other.x)^2 + (self.y - other.y)^2)
end

function Vector:rotate(radians)
  local sin = math.sin(radians)
  local cos = math.cos(radians)
  self.x, self.y = cos * self.x - sin * self.y, sin * self.x + cos * self.y
end
