Ramp = {}
Ramp.__index = Ramp
Ramp.__tostring = function(r)
  local graphic
  if r.left then
    if r.inverted then
      graphic = "\\|"
    else
      graphic = "/|"
    end
  elseif r.inverted then
    graphic = "|/"
  else
    graphic = "|\\"
  end
  return "Ramp " .. graphic .. " (" .. r.x .. ", " .. r.y .. ", " .. r.w .. ", " .. r.h .. ")"
end

function Ramp.new(x, y, w, h, left, inverted)
  local self = setmetatable({}, Ramp)

  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.left = left
  self.inverted = inverted or false

  if Physics.engine == "minigl" then
    self.ratio = h / w
    self.factor = w / math.sqrt(w^2 + h^2)
  elseif Physics.engine == "love" then
    self.body = love.physics.newBody(Physics.world, x + w / 2, y + h / 2)
    points = {}
    if not left or inverted then
      table.insert(points, -w / 2)
      table.insert(points, -h / 2)
    end
    if left or inverted then
      table.insert(points, w / 2)
      table.insert(points, -h / 2)
    end
    if not (left and inverted) then
      table.insert(points, -w / 2)
      table.insert(points, h / 2)
    end
    if left or not inverted then
      table.insert(points, w / 2)
      table.insert(points, h / 2)
    end
    self.shape = love.physics.newPolygonShape(unpack(points))
    love.physics.newFixture(self.body, self.shape)
    self.body:setUserData(self)
  end

  return self
end

function Ramp:contact(obj)
  if self.inverted then return false end
  return obj.x + obj.w > self.x and
    obj.x < self.x + self.w and
    Utils.approx_equal(obj.x, self:get_x(obj)) and
    Utils.approx_equal(obj.y, self:get_y(obj))
end

function Ramp:intersect(obj)
  return obj.x + obj.w > self.x and
    obj.x < self.x + self.w and
    ((self.inverted and obj.y < self:get_y(obj) and obj.y + obj.h > self.y) or
     (not self.inverted and obj.y > self:get_y(obj) and obj.y < self.y + self.h))
end

function Ramp:check_can_collide(m)
  local y = self:get_y(m) + (self.inverted and 0 or m.h)
  self.can_collide = m.x + m.w > self.x and self.x + self.w > m.x and m.y < y and m.y + m.h > y
end

function Ramp:check_intersection(obj)
  if not (self.can_collide and self:intersect(obj)) then return end

  local counter = self.left and obj.prev_speed.x > 0 or not self.left and obj.prev_speed.x < 0
  if counter and ((self.inverted and obj.prev_speed.y < 0) or (not self.inverted and obj.prev_speed.y > 0)) then
    local dx = self:get_x(obj) - obj.x
    local s = math.abs(obj.prev_speed.y / obj.prev_speed.x)
    dx = dx / s + self.ratio
    obj.x = obj.x + dx
  end
  if counter and obj.bottom ~= self then
    obj.speed.x = obj.speed.x * self.factor
  end

  obj.speed.y = 0
  obj.y = self:get_y(obj)
end

function Ramp:get_x(obj)
  if self.left and obj.x + obj.w > self.x + self.w or not self.left and obj.x < self.x then
    return obj.x
  end

  local offset = (self.inverted and obj.y - self.y or self.y + self.h - obj.y - obj.h) * self.w / self.h
  return self.left and self.x + offset - obj.w or self.x + self.w - offset
end

function Ramp:get_y(obj)
  if self.left and obj.x + obj.w > self.x + self.w or not self.left and obj.x < self.x then
    return self.y + (self.inverted and self.h or -obj.h)
  end

  local offset = (self.left and self.x + self.w - obj.x - obj.w or obj.x - self.x) * self.h / self.w
  return self.inverted and self.y + self.h - offset or self.y + offset - obj.h
end

function Ramp:points()
  return self.body:getWorldPoints(self.shape:getPoints())
end
