IsoBlock = {}
IsoBlock.__index = IsoBlock

TYPE_MAP = {
  {1, 1, 1, "block1", 0, 0},           -- 1
  {4, 6, 3, "house1", -10, -48},       -- 2
  {3, 3, 4, "house2", -10, 0},         -- 3
  {1, 1, 7, "tree1", -128, 32},        -- 4
  {3, 2, 1, "bed1", 0, -8},            -- 5
  {1, 1, 3, "bedtable1", 0, 40},       -- 6
  {1, 10, 3, "wall1", 0, -40},         -- 7
  {6, 1, 3, "wall2", 0, -40},          -- 8
  {4, 1, 3, "wall3", 0, -8},           -- 9
  {1, 1, 3, "wall4", 0, -8},           -- 10
  {1, 2, 3, "rack1", -4, 88},          -- 11
  {2, 2, 1, "table1", 0, 8},           -- 12
  {3, 4, 4, "house3", -10, -30},       -- 13
  {6, 2, 5, "house4", -10, -64, true}, -- 14
  {2, 1, 1, "balcony1", 0, 40, true},  -- 15
  {2, 1, 3, "fence1", 0, 24, true},    -- 16
  {4, 3, 4, "house5", -10, -30},       -- 17
}

function IsoBlock.new(type_id, col, row, layer, cols, rows, layers, diagonal, color_or_image, img_gap)
  local self = setmetatable({}, IsoBlock)
  self.col = col
  self.row = row
  self.layer = layer
  if type_id then
    local attrs = TYPE_MAP[type_id]
    cols = attrs[1]
    rows = attrs[2]
    layers = attrs[3]
    color_or_image = "block/" .. attrs[4]
    img_gap = Vector.new(attrs[5], attrs[6])
    diagonal = attrs[7]
  end
  self.cols = cols
  self.rows = rows
  self.layers = layers
  self.diagonal = diagonal
  self.z = layer * PHYSICS_UNIT
  self.height = layers * PHYSICS_UNIT
  self.top = self.z + self.height

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
    for i = 1, cols + rows - 2 do
      local top_row = i < cols and (row - i) or (row - 2 * cols + i + 1)
      local bottom_row = i < rows and (row + i) or (row + 2 * rows - i - 1)
      table.insert(
        self.inner_rects,
        Rectangle.new((col + i - 0.5) * PHYSICS_UNIT, (top_row + 0.5) * PHYSICS_UNIT, PHYSICS_UNIT, (bottom_row - top_row) * PHYSICS_UNIT)
      )
    end

    self.max_z_index = (col + row + rows) * 10000 + (layer + layers) * 100
  else
    self.body = love.physics.newBody(Physics.world, (col + cols / 2) * PHYSICS_UNIT, (row + rows / 2) * PHYSICS_UNIT)
    local shape = love.physics.newRectangleShape(cols * PHYSICS_UNIT, rows * PHYSICS_UNIT)
    love.physics.newFixture(self.body, shape)
    self.body:setUserData(self)
    self.bounds = Rectangle.new(col * PHYSICS_UNIT, row * PHYSICS_UNIT, cols * PHYSICS_UNIT, rows * PHYSICS_UNIT)

    self.max_z_index = (col + row + cols + rows) * 10000 + (layer + layers) * 100
  end

  if type(color_or_image) == "string" then
    self.img_gap = img_gap or Vector.new
    if diagonal then
      self.image = Res.img(color_or_image)
    else
      self.image = {}
      local base_image = Res.img(color_or_image)
      for i = 0, self.cols + self.rows - 1 do
        local x = i * HALF_TILE_WIDTH
        local w = HALF_TILE_WIDTH
        if i == 0 then
          w = w - img_gap.x
        elseif i == self.cols + self.rows - 1 then
          x = x - img_gap.x
          w = base_image.width - ((self.cols + self.rows - 1) * HALF_TILE_WIDTH - img_gap.x)
        else
          x = x - img_gap.x
        end
        table.insert(self.image, Image.new(base_image.source, x, 0, w, base_image.height))
      end
    end
  elseif type(color_or_image) == "table" then
    self.color = color_or_image
    self.shade_color1 = {0.9 * self.color[1], 0.9 * self.color[2], 0.9 * self.color[3]}
    self.shade_color2 = {0.8 * self.color[1], 0.8 * self.color[2], 0.8 * self.color[3]}
  end

  return self
end

function IsoBlock:set_body_active(active)
  if self.diagonal then
    for _, r in ipairs(self.ramps) do
      r.body:setActive(active)
    end
  else
    self.body:setActive(active)
  end
end

function IsoBlock:activate()
  self:set_body_active(true)
end

function IsoBlock:deactivate()
  self:set_body_active(false)
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
  if self.image then
    local base_pos = map:get_screen_pos(self.col, self.row)
    local y = base_pos.y - (self.layer + self.layers) * ISO_UNIT + self.img_gap.y

    if self.diagonal then
      self.image:draw(base_pos.x + self.img_gap.x, y + self.img_gap.y, self.max_z_index)

      return
    end

    local base_x = base_pos.x - (self.rows - 1) * HALF_TILE_WIDTH
    for i = 0, self.cols + self.rows - 1 do
      local x_offset = i == 0 and self.img_gap.x or 0
      local j = i + 1
      local z_ref = j > self.cols and i or j
      local z = (self.col + self.row + self.rows + (z_ref > self.cols and self.cols or z_ref) - (z_ref > self.cols and (z_ref - self.cols) or 0)) * 10000
      z = z + (self.layer + self.layers) * 100
      self.image[i + 1]:draw(base_x + i * HALF_TILE_WIDTH + x_offset, y, z)
    end

    return
  end

  if self.color == nil then return end

  if self.diagonal then
    local base_pos = map:get_screen_pos(self.col + self.rows - 1, self.row + self.rows - 1)
    local bottom_y = base_pos.y + TILE_HEIGHT - self.layer * ISO_UNIT
    local top_y = bottom_y - self.layers * ISO_UNIT
    Window.draw_rectangle(base_pos.x, top_y, self.max_z_index, self.cols * TILE_WIDTH, self.layers * ISO_UNIT, self.shade_color2)
    Window.draw_rectangle(base_pos.x, top_y - self.rows * TILE_HEIGHT, self.max_z_index, self.cols * TILE_WIDTH, self.rows * TILE_HEIGHT, self.color)

    return
  end

  local base_pos = map:get_screen_pos(self.col, self.row + self.rows - 1)
  local bottom_y = base_pos.y + HALF_TILE_HEIGHT - self.layer * ISO_UNIT
  local top_y = bottom_y - self.layers * ISO_UNIT
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
    local z = (self.col + self.row + self.rows + (z_ref > self.cols and self.cols or z_ref) - (z_ref > self.cols and (z_ref - self.cols) or 0)) * 10000
    z = z + (self.layer + self.layers) * 100
    Window.draw_polygon(z, self.color, "fill", x1, y1, x2, y2, x2, y4, x1, y3)
    Window.draw_polygon(z, j > self.cols and self.shade_color2 or self.shade_color1, "fill", x1, y3, x2, y4, x2, y6, x1, y5)
  end
end
