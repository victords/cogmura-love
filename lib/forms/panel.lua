Panel = {}
Panel.__index = Panel

function Panel.new(x, y, w, h, components, options)
  local self = setmetatable({}, Panel)
  local _, new_x, new_y = Utils.check_anchor(options.anchor, x, y, w, h)
  self.x = new_x
  self.y = new_y
  self.w = w
  self.h = h
  self.components = components
  for _, c in ipairs(components) do
    _, new_x, new_y = Utils.check_anchor(c.anchor, c.anchor_offset_x, c.anchor_offset_y, c.w, c.h, self.w, self.h)
    c:set_position(self.x + new_x, self.y + new_y)
    c.panel = self
  end

  if options.img_path then
    self.tiled = options.tiled
    if self.tiled then
      self.scale = options.scale or 1
      self.img = Res.tileset(options.img_path, 3, 3)
      self.border_w = self.scale * self.img.tile_width
      self.border_h = self.scale * self.img.tile_height
      self.center_scale_x = (self.w - 2 * self.border_w) / self.img.tile_width
      self.center_scale_y = (self.h - 2 * self.border_h) / self.img.tile_height
    else
      self.img = Res.img(options.img_path)
      self.scale_x = self.w / self.img.width
      self.scale_y = self.h / self.img.height
    end
  end

  if options.clip then
    self.clip = true
    self.shader = Res.shader("clip")
    self.shader:send("x", self.x)
    self.shader:send("y", self.y)
    self.shader:send("w", self.w)
    self.shader:send("h", self.h)

    self.scroll_x = 0
    self.scroll_y = 0
    self.total_w = options.total_w or self.w
    self.total_h = options.total_h or self.h
    self.scroll_speed = options.scroll_speed or 1
  end
  self.enabled = true
  self.visible = true
  return self
end

function Panel:update()
  if not (self.enabled and self.visible) then return end

  local scroll_x = 0
  local scroll_y = 0
  if self.clip then
    if self.scroll_x + self.w < self.total_w and KB.down("right") then
      scroll_x = self.scroll_x + self.w + self.scroll_speed > self.total_w
        and self.total_w - self.w - self.scroll_x
        or self.scroll_speed
    elseif self.scroll_x > 0 and KB.down("left") then
      scroll_x = self.scroll_x < self.scroll_speed
        and -self.scroll_x
        or -self.scroll_speed
    end
    if self.scroll_y + self.h < self.total_h and KB.down("down") then
      scroll_y = self.scroll_y + self.h + self.scroll_speed > self.total_h
        and self.total_h - self.h - self.scroll_y
        or self.scroll_speed
    elseif self.scroll_y > 0 and KB.down("up") then
      scroll_y = self.scroll_y < self.scroll_speed
        and -self.scroll_y
        or -self.scroll_speed
    end
    self.scroll_x = self.scroll_x + scroll_x
    self.scroll_y = self.scroll_y + scroll_y
  end

  for _, c in ipairs(self.components) do
    if scroll_x ~= 0 or scroll_y ~= 0 then
      c:set_position(c.x - scroll_x, c.y - scroll_y)
    end
    c:update()
  end
end

function Panel:set_enabled(value)
  self.enabled = value
  for _, c in ipairs(self.components) do
    c:set_enabled(value)
  end
end

function Panel:add_component(c)
  local _, x, y = Utils.check_anchor(c.anchor, c.anchor_offset_x, c.anchor_offset_y, c.w, c.h, self.w, self.h)
  c:set_position(self.x + new_x, self.y + new_y)
  table.insert(self.components, c)
end

function Panel:draw(color, z_index)
  if not self.visible then return end

  if self.tiled then
    -- corners
    self.img[1]:draw(self.x, self.y, z_index, self.scale, self.scale, nil, color)
    self.img[3]:draw(self.x + self.w - self.border_w, self.y, z_index, self.scale, self.scale, nil, color)
    self.img[7]:draw(self.x, self.y + self.h - self.border_h, z_index, self.scale, self.scale, nil, color)
    self.img[9]:draw(self.x + self.w - self.border_w, self.y + self.h - self.border_h, z_index, self.scale, self.scale, nil, color)

    -- horizontal middle
    if self.w > 2 * self.border_w then
      self.img[2]:draw(self.x + self.border_w, self.y, z_index, self.center_scale_x, self.scale, nil, color)
      self.img[8]:draw(self.x + self.border_w, self.y + self.h - self.border_h, z_index, self.center_scale_x, self.scale, nil, color)

      -- center
      if self.h > 2 * self.border_h then
        self.img[5]:draw(self.x + self.border_w, self.y + self.border_h, z_index, self.center_scale_x, self.center_scale_y, nil, color)
      end
    end

    -- vertical middle
    if self.h > 2 * self.border_h then
      self.img[4]:draw(self.x, self.y + self.border_h, z_index, self.scale, self.center_scale_y, nil, color)
      self.img[6]:draw(self.x + self.w - self.border_w, self.y + self.border_h, z_index, self.scale, self.center_scale_y, nil, color)
    end
  elseif self.img then
    self.img:draw(self.x, self.y, z_index, self.scale_x, self.scale_y, nil, color)
  end

  if self.shader then
    love.graphics.setShader(self.shader)
  end
  for _, c in ipairs(self.components) do
    c:draw(color, z_index)
  end
  if self.shader then
    love.graphics.setShader()
  end
end
