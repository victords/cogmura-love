Scene = {}
Scene.__index = Scene

function Scene.new()
  local self = setmetatable({}, Scene)
  --self.font = Res.font("font", 48)
  self.map = Map.new(96, 48, 20, 20, Window.reference_width, Window.reference_height, true, false)
  return self
end

function Scene:update()
end

function Scene:draw()
  self.map:foreach(function(i, j, x, y)
    local color = (i + j) % 2 == 0 and {0.15, 0.6, 0} or {0.3, 0.8, 0}
    love.graphics.setColor(color)
    love.graphics.polygon("fill", x + 48, y, x + 96, y + 24, x + 48, y + 48, x, y + 24)
  end)
  love.graphics.setColor(1, 1, 1)
end
