Map = {}
Map.__index = Map

local SQRT_2_DIV_2 = math.sqrt(2) / 2
local MINUS_PI_DIV_4 = -math.pi / 4

function Map.new(t_w, t_h, t_x_count, t_y_count, scr_w, scr_h, isometric, limit_cam)
  scr_w = scr_w or love.graphics.getWidth()
  scr_h = scr_h or love.graphics.getHeight()
  if limit_cam == nil then limit_cam = true end

  local self = setmetatable({}, Map)
  self.tile_size = Vector.new(t_w, t_h)
  self.size = Vector.new(t_x_count, t_y_count)
  self.cam = Rectangle.new(0, 0, scr_w, scr_h)
  self.limit_cam = limit_cam
  self.isometric = isometric
  if isometric then
    self:initialize_isometric()
  elseif limit_cam then
    self.max_x = t_x_count * t_w - scr_w
    self.max_y = t_y_count * t_h - scr_h
  end
  self:set_camera(0, 0)
  return self
end

function Map:absolute_size()
  if self.isometric then
    local avg = (self.size.x + self.size.y) * 0.5
    return Vector.new(math.floor(avg * self.tile_size.x), math.floor(avg * self.tile_size.y))
  end

  return Vector.new(self.tile_size.x * self.size.x, self.tile_size.y * self.size.y)
end

function Map:get_center()
  local absolute_size = self:absolute_size()
  return Vector.new(absolute_size.x * 0.5, absolute_size.y * 0.5)
end

function Map:get_screen_pos(map_x, map_y)
  if self.isometric then
    return Vector.new(
      ((map_x - map_y - 1) * self.tile_size.x * 0.5) - self.cam.x + self.x_offset,
      ((map_x + map_y) * self.tile_size.y * 0.5) - self.cam.y
    )
  end

  return Vector.new(map_x * self.tile_size.x - self.cam.x, map_y * self.tile_size.y - self.cam.y)
end

function Map:get_map_pos(scr_x, scr_y)
  if self.isometric then
    -- Gets the position transformed to isometric coordinates
    local v = self:get_isometric_position(scr_x, scr_y)

    -- divides by the square size to find the position in the matrix
    return Vector.new(math.floor(v.x * self.inverse_square_size), math.floor(v.y * self.inverse_square_size))
  end

  return Vector.new(math.floor((scr_x + self.cam.x) / self.tile_size.x), math.floor((scr_y + self.cam.y) / self.tile_size.y))
end

function Map:is_in_map(v)
  return v.x >= 0 and v.y >= 0 and v.x < self.size.x and v.y < self.size.y
end

function Map:set_camera(cam_x, cam_y)
  self.cam.x = cam_x
  self.cam.y = cam_y
  self:set_bounds()
end

function Map:move_camera(x, y)
  self.cam.x = self.cam.x + x
  self.cam.y = self.cam.y + y
  self:set_bounds()
end

function Map:foreach(callback)
  for j = self.min_vis_y, self.max_vis_y do
    for i = self.min_vis_x, self.max_vis_x do
      local pos = self:get_screen_pos(i, j)
      callback(i, j, pos.x, pos.y)
    end
  end
end

-- private
function Map:set_bounds()
  if self.limit_cam then
    if self.isometric then
      local v1 = self:get_isometric_position(0, 0)
      local v2 = self:get_isometric_position(self.cam.w - 1, 0)
      local v3 = self:get_isometric_position(self.cam.w - 1, self.cam.h - 1)
      local v4 = self:get_isometric_position(0, self.cam.h - 1)
      if v1.x < -self.max_offset then
        offset = -(v1.x + self.max_offset)
        self.cam.x = self.cam.x + offset * SQRT_2_DIV_2
        self.cam.y = self.cam.y + offset * SQRT_2_DIV_2 / self.tile_ratio
      end
      if v2.y < -self.max_offset then
        offset = -(v2.y + self.max_offset)
        self.cam.x = self.cam.x - offset * SQRT_2_DIV_2
        self.cam.y = self.cam.y + offset * SQRT_2_DIV_2 / self.tile_ratio
      end
      if v3.x > self.iso_abs_size.x + self.max_offset then
        offset = v3.x - self.iso_abs_size.x - self.max_offset
        self.cam.x = self.cam.x - offset * SQRT_2_DIV_2
        self.cam.y = self.cam.y - offset * SQRT_2_DIV_2 / self.tile_ratio
      end
      if v4.y > self.iso_abs_size.y + self.max_offset then
        offset = v4.y - self.iso_abs_size.y - self.max_offset
        self.cam.x = self.cam.x + offset * SQRT_2_DIV_2
        self.cam.y = self.cam.y - offset * SQRT_2_DIV_2 / self.tile_ratio
      end
    else
      if self.cam.x > self.max_x then self.cam.x = self.max_x end
      if self.cam.x < 0 then self.cam.x = 0 end
      if self.cam.y > self.max_y then self.cam.y = self.max_y end
      if self.cam.y < 0 then self.cam.y = 0 end
    end
  end

  self.cam.x = Utils.round(self.cam.x)
  self.cam.y = Utils.round(self.cam.y)
  if self.isometric then
    self.min_vis_x = self:get_map_pos(0, 0).x
    self.min_vis_y = self:get_map_pos(self.cam.w - 1, 0).y
    self.max_vis_x = self:get_map_pos(self.cam.w - 1, self.cam.h - 1).x
    self.max_vis_y = self:get_map_pos(0, self.cam.h - 1).y
  else
    self.min_vis_x = math.floor(self.cam.x / self.tile_size.x)
    self.min_vis_y = math.floor(self.cam.y / self.tile_size.y)
    self.max_vis_x = math.floor((self.cam.x + self.cam.w - 1) / self.tile_size.x)
    self.max_vis_y = math.floor((self.cam.y + self.cam.h - 1) / self.tile_size.y)
  end

  if self.min_vis_y < 0 then
    self.min_vis_y = 0
  elseif self.min_vis_y > self.size.y - 1 then
    self.min_vis_y = self.size.y - 1
  end

  if self.max_vis_y < 0 then
    self.max_vis_y = 0
  elseif self.max_vis_y > self.size.y - 1 then
    self.max_vis_y = self.size.y - 1
  end

  if self.min_vis_x < 0 then
    self.min_vis_x = 0
  elseif self.min_vis_x > self.size.x - 1 then
    self.min_vis_x = self.size.x - 1
  end

  if self.max_vis_x < 0 then
    self.max_vis_x = 0
  elseif self.max_vis_x > self.size.x - 1 then
    self.max_vis_x = self.size.x - 1
  end
end

function Map:initialize_isometric()
  self.x_offset = Utils.round(self.size.y * 0.5 * self.tile_size.x)
  self.tile_ratio = self.tile_size.x / self.tile_size.y
  local square_size = self.tile_size.x * SQRT_2_DIV_2
  self.inverse_square_size = 1 / square_size
  self.iso_abs_size = Vector.new(square_size * self.size.x, square_size * self.size.y)
  local a = (self.size.x + self.size.y) * 0.5 * self.tile_size.x
  self.isometric_offset = Vector.new(
    (a - square_size * self.size.x) * 0.5,
    (a - square_size * self.size.y) * 0.5
  )
  if not self.limit_cam then return end

  local actual_cam_h = self.cam.h * self.tile_ratio
  self.max_offset = actual_cam_h < self.cam.w and actual_cam_h or self.cam.w
  self.max_offset = self.max_offset * SQRT_2_DIV_2
end

function Map:get_isometric_position(scr_x, scr_y)
  -- Gets the position relative to the center of the map
  local center = self:get_center()
  local position = Vector.new(scr_x + self.cam.x - center.x, scr_y + self.cam.y - center.y)

  -- Multiplies by tile_ratio to get square tiles
  position.y = position.y * self.tile_ratio

  -- Moves the center of the map accordingly
  center.y = center.y * self.tile_ratio

  -- Rotates the position -45 degrees
  position:rotate(MINUS_PI_DIV_4)

  -- Returns the reference to the center of the map
  position = position + center

  -- Returns to the corner of the screen
  position = position - self.isometric_offset

  return position
end
