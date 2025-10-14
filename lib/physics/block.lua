Block = {}
Block.__index = Block
Block.__tostring = function(b)
  return "Block (" .. b.x .. ", " .. b.y .. ", " .. b.w .. ", " .. b.h .. ")"
end

function Block.new(x, y, w, h, passable)
  local self = setmetatable({}, Block)

  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.passable = passable or false

  if Physics.engine == "love" then
    self.body = love.physics.newBody(Physics.world, x + w / 2, y + h / 2)
    self.shape = love.physics.newRectangleShape(w, h)
    love.physics.newFixture(self.body, self.shape)
    self.body:setUserData(self)
  end

  return self
end

function Block:bounds()
  if Physics.engine == "love" then return nil end

  return Rectangle.new(self.x, self.y, self.w, self.h)
end

function Block:points()
  if Physics.engine == "minigl" then return nil end

  return self.body:getWorldPoints(self.shape:getPoints())
end
