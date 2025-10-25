Scene = {}
Scene.__index = Scene

function Scene.new()
  local self = setmetatable({}, Scene)
  self.font = Res.font("font", 48)
  return self
end

function Scene:update()
end

function Scene:draw()
  self.font:draw_text_rel("This is a scene", 640, 360, 0.5, 0.5)
end
