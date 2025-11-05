Image = {}
Image.__index = Image

function Image.new(path_or_source, source_x, source_y, source_w, source_h)
  local self = setmetatable({}, Image)
  self.source = type(path_or_source) == "string" and love.graphics.newImage(path_or_source) or path_or_source

  local img_width = self.source:getWidth()
  local img_height = self.source:getHeight()
  self.width = source_w or img_width
  self.height = source_h or img_height
  self.quad = source_x and source_y and source_w and source_h and
    love.graphics.newQuad(source_x, source_y, source_w, source_h, img_width, img_height)

  return self
end

function Image:draw(x, y, z, scale_x, scale_y, angle, color)
  scale_x = scale_x or 1
  scale_y = scale_y or 1
  angle = angle and (angle * math.pi / 180)
  local origin_x = 0.5 * self.width
  local origin_y = 0.5 * self.height

  Window.draw_image(self.source, x + scale_x * origin_x, y + scale_y * origin_y, z, color, scale_x, scale_y, angle, origin_x, origin_y, self.quad)
end

function Image.set_retro()
  love.graphics.setDefaultFilter("nearest", "nearest")
end
