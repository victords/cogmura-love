PrimitiveImage = {}
PrimitiveImage.__index = PrimitiveImage

function PrimitiveImage.new(width, height, ...)
  local self = setmetatable({}, PrimitiveImage)
  self.shapes = {...}
  self.canvas = love.graphics.newCanvas(width, height)
  self.needs_redraw = true

  Window.on_toggle(PrimitiveImage.on_window_toggle, self)

  return self
end

function PrimitiveImage:on_window_toggle()
  self.needs_redraw = true
end

function PrimitiveImage:draw(x, y, z)
  if self.needs_redraw then
    love.graphics.setCanvas(self.canvas)
    for _, shape in ipairs(self.shapes) do
      love.graphics.setColor(shape.color or {1, 1, 1})
      if shape.type == "rectangle" then
        love.graphics.rectangle("fill", shape.x, shape.y, shape.w, shape.h)
      elseif shape.type == "circle" then
        love.graphics.circle("fill", shape.x, shape.y, shape.radius)
      end
    end
    love.graphics.setCanvas(Window.canvas)
    love.graphics.setColor(1, 1, 1)

    self.needs_redraw = false
  end

  Window.draw_canvas(self.canvas, x, y, z)
end
