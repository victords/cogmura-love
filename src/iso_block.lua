IsoBlock = {}
IsoBlock.__index = IsoBlock

function IsoBlock.new(col, row, layer, cols, rows, height, diagonal, color)
  local self = setmetatable({}, IsoBlock)
  self.col = col
  self.row = row
  self.layer = layer
  self.cols = cols
  self.rows = rows
  self.height = height
  self.z = layer * PHYSICS_UNIT
  self.top = (layer + height) * PHYSICS_UNIT
  self.diagonal = diagonal

  if diagonal then
    self.ramps = {}
    for i = 0, cols - 1 do
      table.insert(self.ramps, Ramp.new((col + i - 0.5) * PHYSICS_UNIT, (row - i - 0.5) * PHYSICS_UNIT, PHYSICS_UNIT, PHYSICS_UNIT, true, false))
      table.insert(self.ramps, Ramp.new((col + rows + i - 0.5) * PHYSICS_UNIT, (row + rows - i - 0.5) * PHYSICS_UNIT, PHYSICS_UNIT, PHYSICS_UNIT, false, true))
    end
    for i = 0, rows - 1 do
      table.insert(self.ramps, Ramp.new((col + i - 0.5) * PHYSICS_UNIT, (row + i + 0.5) * PHYSICS_UNIT, PHYSICS_UNIT, PHYSICS_UNIT, true, true))
      table.insert(self.ramps, Ramp.new((col + cols + i - 0.5) * PHYSICS_UNIT, (row - cols + i + 0.5) * PHYSICS_UNIT, PHYSICS_UNIT, PHYSICS_UNIT, false, false))
    end

    self.inner_rects = {}
    for i = 0, cols + rows - 2 do
      local top_row = i < cols and (row - i) or (row - 2 * cols + i + 2)
      local bottom_row = i < rows and (row + i + 1) or (row + 2 * rows - i - 1)
      table.insert(
        self.inner_rects,
        Rectangle.new((col + i) * PHYSICS_UNIT, top_row * PHYSICS_UNIT, PHYSICS_UNIT, (bottom_row - top_row) * PHYSICS_UNIT)
      )
    end

    self.max_z_index = ((col + row) * HALF_TILE_HEIGHT + rows * TILE_HEIGHT) * 100 + layer + height
  else
    self.body = love.physics.newBody(Physics.world, (col + cols / 2) * PHYSICS_UNIT, (row + rows / 2) * PHYSICS_UNIT)
    local shape = love.physics.newRectangleShape(cols * PHYSICS_UNIT, rows * PHYSICS_UNIT)
    love.physics.newFixture(self.body, shape)
    self.body:setUserData(self)
    self.bounds = Rectangle.new(col * PHYSICS_UNIT, row * PHYSICS_UNIT, cols * PHYSICS_UNIT, rows * PHYSICS_UNIT)

    self.max_z_index = (col + row + cols + rows) * HALF_TILE_HEIGHT * 100 + layer + height
  end

  self.color = color or {1, 1, 1}
  self.shade_color1 = {0.9 * self.color[1], 0.9 * self.color[2], 0.9 * self.color[3]}
  self.shade_color2 = {0.8 * self.color[1], 0.8 * self.color[2], 0.8 * self.color[3]}

  return self
end

function IsoBlock:setBodyActive(active)
  if self.diagonal then
    for _, r in ipairs(self.ramps) do
      r.body:setActive(active)
    end
  else
    self.body:setActive(active)
  end
end

function IsoBlock:intersect(rect)
  if self.diagonal then
    for _, r in ipairs(self.ramps) do
      if r:intersect(rect) then return true end
    end
    for _, r in ipairs(self.inner_rects) do
      if r:intersect(rect) then return true end
    end
    return false
  else
    return self.bounds:intersect(rect)
  end
end

function IsoBlock:draw(map)
  if self.diagonal then
    local base_pos = map:get_screen_pos(self.col + self.rows - 1, self.row + self.rows - 1)
    local bottom_y = base_pos.y + TILE_HEIGHT - self.layer * ISO_UNIT
    local top_y = bottom_y - self.height * ISO_UNIT
    Window.draw_rectangle(base_pos.x, top_y, self.max_z_index, self.cols * TILE_WIDTH, self.height * ISO_UNIT, self.shade_color2)
    Window.draw_rectangle(base_pos.x, top_y - self.rows * TILE_HEIGHT, self.max_z_index, self.cols * TILE_WIDTH, self.rows * TILE_HEIGHT, self.color)

    return
  end

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
    z = z + self.layer + self.height
    Window.draw_polygon(z, self.color, "fill", x1, y1, x2, y2, x2, y4, x1, y3)
    Window.draw_polygon(z, j > self.cols and self.shade_color2 or self.shade_color1, "fill", x1, y3, x2, y4, x2, y6, x1, y5)
  end
end
