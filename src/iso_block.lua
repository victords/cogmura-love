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
  self.z_index = (col + row + 2) * HALF_TILE_HEIGHT * 100 + layer

  self.body = love.physics.newBody(Physics.world, (col + 0.5) * PHYSICS_UNIT, (row + 0.5) * PHYSICS_UNIT)
  self.shape = love.physics.newRectangleShape(PHYSICS_UNIT, PHYSICS_UNIT)
  love.physics.newFixture(self.body, self.shape)
  self.body:setUserData(self)

  return self
end

function IsoBlock:draw(map)
  local base_pos = map:get_screen_pos(self.col, self.row)
  local bottom_y = base_pos.y + HALF_TILE_HEIGHT - self.layer * ISO_UNIT
  local top_y = bottom_y - self.height * ISO_UNIT
  Window.draw_polygon(self.z_index, {1, 1, 1}, "fill",
                      base_pos.x, top_y,
                      base_pos.x + HALF_TILE_WIDTH, top_y - HALF_TILE_HEIGHT,
                      base_pos.x + TILE_WIDTH, top_y,
                      base_pos.x + HALF_TILE_WIDTH, top_y + HALF_TILE_HEIGHT)
  Window.draw_polygon(self.z_index, {0.9, 0.9, 0.9}, "fill",
                      base_pos.x, top_y,
                      base_pos.x + HALF_TILE_WIDTH, top_y + HALF_TILE_HEIGHT,
                      base_pos.x + HALF_TILE_WIDTH, bottom_y + HALF_TILE_HEIGHT,
                      base_pos.x, bottom_y)
  Window.draw_polygon(self.z_index, {0.8, 0.8, 0.8}, "fill",
                      base_pos.x + HALF_TILE_WIDTH, top_y + HALF_TILE_HEIGHT,
                      base_pos.x + TILE_WIDTH, top_y,
                      base_pos.x + TILE_WIDTH, bottom_y,
                      base_pos.x + HALF_TILE_WIDTH, bottom_y + HALF_TILE_HEIGHT)
end
