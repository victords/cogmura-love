IsoBlock = {}
IsoBlock.__index = IsoBlock

function IsoBlock.new(col, row, layer, cols, rows, height, color)
  local self = setmetatable({}, IsoBlock)
  self.col = col
  self.row = row
  self.layer = layer
  self.cols = cols
  self.rows = rows
  self.height = height

  self.body = love.physics.newBody(Physics.world, (col + cols / 2) * PHYSICS_UNIT, (row + rows / 2) * PHYSICS_UNIT)
  self.shape = love.physics.newRectangleShape(cols * PHYSICS_UNIT, rows * PHYSICS_UNIT)
  love.physics.newFixture(self.body, self.shape)
  self.body:setUserData(self)

  self.color = color or {1, 1, 1}
  self.shade_color1 = {0.9 * self.color[1], 0.9 * self.color[2], 0.9 * self.color[3]}
  self.shade_color2 = {0.8 * self.color[1], 0.8 * self.color[2], 0.8 * self.color[3]}

  return self
end

function IsoBlock:bounds()
  return Rectangle.new(self.col * PHYSICS_UNIT, self.row * PHYSICS_UNIT, self.cols * PHYSICS_UNIT, self.rows * PHYSICS_UNIT)
end

function IsoBlock:draw(map)
  local base_pos = map:get_screen_pos(self.col, self.row + self.rows - 1)
  local bottom_y = base_pos.y + HALF_TILE_HEIGHT - self.layer * ISO_UNIT
  local top_y = bottom_y - self.height * ISO_UNIT
  for i = 0, self.cols + self.rows - 1 do
    local j = i + 1
    local x1 = base_pos.x + i * HALF_TILE_WIDTH
    local x2 = x1 + HALF_TILE_WIDTH
    local y1 = top_y - (i > self.rows and self.rows or i) * HALF_TILE_HEIGHT + (i > self.rows and (i - self.rows) or 0) * HALF_TILE_HEIGHT
    local y2 = top_y - (j > self.rows and self.rows or j) * HALF_TILE_HEIGHT + (j > self.rows and (j - self.rows) or 0) * HALF_TILE_HEIGHT
    local y3 = top_y + (i > self.cols and self.cols or i) * HALF_TILE_HEIGHT - (i > self.cols and (i - self.cols) or 0) * HALF_TILE_HEIGHT
    local y4 = top_y + (j > self.cols and self.cols or j) * HALF_TILE_HEIGHT - (j > self.cols and (j - self.cols) or 0) * HALF_TILE_HEIGHT
    local y5 = bottom_y + (i > self.cols and self.cols or i) * HALF_TILE_HEIGHT - (i > self.cols and (i - self.cols) or 0) * HALF_TILE_HEIGHT
    local y6 = bottom_y + (j > self.cols and self.cols or j) * HALF_TILE_HEIGHT - (j > self.cols and (j - self.cols) or 0) * HALF_TILE_HEIGHT
    local z_ref = j > self.cols and i or j
    local z = (self.col + self.row + self.rows + (z_ref > self.cols and self.cols or z_ref) - (z_ref > self.cols and (z_ref - self.cols) or 0)) * HALF_TILE_HEIGHT * 100
    Window.draw_polygon(z, self.color, "fill", x1, y1, x2, y2, x2, y4, x1, y3)
    Window.draw_polygon(z, j > self.cols and self.shade_color2 or self.shade_color1, "fill", x1, y3, x2, y4, x2, y6, x1, y5)
  end
end
