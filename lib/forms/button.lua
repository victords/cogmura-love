Button = setmetatable({}, Component)
Button.__index = Button

function Button.new(x, y, options, action)
  local scale = options.scale or 1
  local img, w, h
  if options.img_path then
    local cols = options.cols or 1
    img = Res.tileset(options.img_path, cols, 4)
    w = scale * img.tile_width
    h = scale * img.tile_height
  else
    w = options.w or 100
    h = options.h or 30
  end

  local self = Component.new(x, y, w, h, options)
  setmetatable(self, Button)

  self.img = img
  self.scale = scale
  self.draw_rect = options.draw_rect == nil or options.draw_rect
  self.over_text_color = options.over_text_color or {0, 0, 0}
  self.down_text_color = options.down_text_color or {0, 0, 0}
  self.center_x = options.center_x == nil or options.center_x
  self.center_y = options.center_y == nil or options.center_y
  self.margin_x = options.margin_x or 0
  self.margin_y = options.margin_y or 0
  self.params = options.params
  self.action = action
  self.state = "up"
  self.img_index = 1

  self:set_text_position()
  return self
end

function Button:update()
  if not (self.enabled and self.visible) then return end

  local mouse_over = Mouse.over(self:get_bounds())
  local mouse_press = Mouse.pressed("left") and not Mouse.click_captured
  local mouse_rel = Mouse.released("left")

  if self.state == "up" then
    if mouse_over then
      self.img_index = 2
      self.state = "over"
    else
      self.img_index = 1
    end
  elseif self.state == "over" then
    if not mouse_over then
      self.img_index = 1
      self.state = "up"
    elseif mouse_press then
      self.img_index = 3
      self.state = "down"
      Mouse.click_captured = true
    else
      self.img_index = 2
    end
  elseif self.state == "down" then
    if not mouse_over then
      self.img_index = 1
      self.state = "down_out"
    elseif mouse_rel then
      self.img_index = 2
      self.state = "over"
      self:click()
    else
      self.img_index = 3
    end
  else -- down_out
    if mouse_over then
      self.img_index = 3
      self.state = "down"
    elseif mouse_rel then
      self.img_index = 1
      self.state = "up"
    else
      self.img_index = 1
    end
  end
end

function Button:draw(color)
  if not self.visible then return end

  if self.img then
    self.img[self.img_index]:draw(self.x, self.y, self.scale, self.scale, nil, color)
  elseif self.draw_rect then
    local rect_color = Utils.clone(color or {1, 1, 1})
    if self.state == "over" then
      rect_color[1] = rect_color[1] * 0.8
      rect_color[2] = rect_color[2] * 0.8
      rect_color[3] = rect_color[3] * 0.8
    elseif self.state == "down" then
      rect_color[1] = rect_color[1] * 0.6
      rect_color[2] = rect_color[2] * 0.6
      rect_color[3] = rect_color[3] * 0.6
    end
    Window.draw_rectangle(self.x, self.y, self.w, self.h, rect_color)
  end

  if self.font == nil or self.text == nil or self.text == "" then return end

  local rel_x = self.center_x and 0.5 or 0
  local rel_y = self.center_y and 0.5 or 0
  local text_color
  if self.enabled then
    text_color = self.state == "over" and self.over_text_color or (self.state == "down" and self.down_text_color or self.text_color)
  else
    text_color = self.disabled_text_color
  end
  self.font:draw_text_rel(self.text, self.text_x, self.text_y, rel_x, rel_y, text_color, self.scale)
end

function Button:set_position(x, y)
  self.x = x
  self.y = y
  self:set_text_position()
end

function Button:set_enabled(value)
  self.enabled = value
  self.state = "up"
  self.img_index = value and 1 or 4
end

function Button:set_text(text)
  self.text = text
  self:set_text_position()
end

function Button:click()
  if self.action then self.action(self.params) end
end

-- private
function Button:set_text_position()
  self.text_x = (self.center_x and self.x + self.w / 2 or self.x) + self.margin_x
  self.text_y = (self.center_y and self.y + self.h / 2 or self.y) + self.margin_y
end
