IsoBlock = {}
IsoBlock.__index = IsoBlock

function IsoBlock.new(col, row, layer, cols, rows, height)
  local self = setmetatable({}, IsoBlock)
  self.col = col
  self.row = row
  self.layer = layer
  self.cols = cols
  self.rows = rows
  self.height = height

  -- z_index calculated based on the bottom-most corner of the block;
  -- each increment in col/row corresponds to HALF_TILE_HEIGHT pixels;
  -- each pixel row allows for 100 layers.
  self.z_index = (col + row + cols + rows) * HALF_TILE_HEIGHT * 100 + layer

  self.body = love.physics.newBody(Physics.world, (col + cols / 2) * PHYSICS_UNIT, (row + rows / 2) * PHYSICS_UNIT)
  self.shape = love.physics.newRectangleShape(cols * PHYSICS_UNIT, rows * PHYSICS_UNIT)
  love.physics.newFixture(self.body, self.shape)
  self.body:setUserData(self)

  return self
end

function IsoBlock:bounds()
  return Rectangle.new(self.col * PHYSICS_UNIT, self.row * PHYSICS_UNIT, self.cols * PHYSICS_UNIT, self.rows * PHYSICS_UNIT)
end

function IsoBlock:draw(map)
  local base_pos = map:get_screen_pos(self.col, self.row + self.rows - 1)
  local bottom_y = base_pos.y + HALF_TILE_HEIGHT - self.layer * ISO_UNIT
  local top_y = bottom_y - self.height * ISO_UNIT
  Window.draw_polygon(self.z_index, {1, 1, 1}, "fill",
                      base_pos.x, top_y,
                      base_pos.x + self.rows * HALF_TILE_WIDTH, top_y - self.rows * HALF_TILE_HEIGHT,
                      base_pos.x + (self.cols + self.rows) * HALF_TILE_WIDTH, top_y + (self.cols - self.rows) * HALF_TILE_HEIGHT,
                      base_pos.x + self.cols * HALF_TILE_WIDTH, top_y + self.cols * HALF_TILE_HEIGHT)
  Window.draw_polygon(self.z_index, {0.9, 0.9, 0.9}, "fill",
                      base_pos.x, top_y,
                      base_pos.x + self.cols * HALF_TILE_WIDTH, top_y + self.cols * HALF_TILE_HEIGHT,
                      base_pos.x + self.cols * HALF_TILE_WIDTH, bottom_y + self.cols * HALF_TILE_HEIGHT,
                      base_pos.x, bottom_y)
  Window.draw_polygon(self.z_index, {0.8, 0.8, 0.8}, "fill",
                      base_pos.x + self.cols * HALF_TILE_WIDTH, top_y + self.cols * HALF_TILE_HEIGHT,
                      base_pos.x + (self.cols + self.rows) * HALF_TILE_WIDTH, top_y + (self.cols - self.rows) * HALF_TILE_HEIGHT,
                      base_pos.x + (self.cols + self.rows) * HALF_TILE_WIDTH, bottom_y + (self.cols - self.rows) * HALF_TILE_HEIGHT,
                      base_pos.x + self.cols * HALF_TILE_WIDTH, bottom_y + self.cols * HALF_TILE_HEIGHT)
end
