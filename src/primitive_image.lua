PrimitiveImage = {}
PrimitiveImage.__index = PrimitiveImage

DEGREES_TO_RADIANS = math.pi / 180

function PrimitiveImage.new(width, height, ...)
  local self = setmetatable({}, PrimitiveImage)
  self.shapes = {...}
  self.canvas = love.graphics.newCanvas(width, height)
  self.width = width
  self.height = height
  self.needs_redraw = true

  Window.on_toggle(PrimitiveImage.on_window_toggle, self)

  return self
end

function PrimitiveImage.parse(data)
  local shapes_data = Utils.split(data, "!")
  local shapes = {}
  local img_width = nil
  local img_height = nil
  for _, shape_data in ipairs(shapes_data) do
    local s_a = Utils.map(Utils.split(shape_data:sub(2), ","), function(s) return tonumber(s) end)
    if shape_data:sub(1, 1) == "r" then
      color = {s_a[5], s_a[6], s_a[7]}
      table.insert(shapes, { type = "rectangle", x = s_a[1], y = s_a[2], w = s_a[3], h = s_a[4], color = color })
    elseif shape_data:sub(1, 1) == "c" then
      color = {s_a[4], s_a[5], s_a[6]}
      table.insert(shapes, { type = "circle", x = s_a[1], y = s_a[2], radius = s_a[3], color = color })
    elseif shape_data:sub(1, 1) == "a" then
      color = {s_a[6], s_a[7], s_a[8]}
      table.insert(shapes, { type = "arc", x = s_a[1], y = s_a[2], radius = s_a[3], a1 = s_a[4], a2 = s_a[5], color = color })
    elseif shape_data:sub(1, 1) == "s" then
      img_width = s_a[1]
      img_height = s_a[2]
    end
  end

  return PrimitiveImage.new(img_width, img_height, unpack(shapes))
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
      elseif shape.type == "arc" then
        love.graphics.arc("fill", shape.x, shape.y, shape.radius, shape.a1 * DEGREES_TO_RADIANS, shape.a2 * DEGREES_TO_RADIANS)
      end
    end
    love.graphics.setCanvas(Window.canvas)
    love.graphics.setColor(1, 1, 1)

    self.needs_redraw = false
  end

  Window.draw_canvas(self.canvas, x, y, z)
end
