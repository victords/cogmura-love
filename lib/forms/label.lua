Label = setmetatable({}, Component)
Label.__index = Label

function Label.new(x, y, options)
  local scale = options.scale or 1
  local font = options.font
  local text = options.text
  local w = font:text_width(text) * scale
  local h = font.height * scale

  local self = Component.new(x, y, w, h, options)
  setmetatable(self, Label)
  self.scale = scale
  self.color = options.color or options.text_color or {1, 1, 1}
  return self
end

function Label:set_text(text)
  self.text = text
  self.w = self.font:text_width(text) * self.scale
  local area_w = self.panel and self.panel.w
  local area_h = self.panel and self.panel.h
  local _, x, y = Utils.check_anchor(self.anchor, self.anchor_offset_x, self.anchor_offset_y, self.w, self.h, area_w, area_h)
  if self.panel then
    self:set_position(self.panel.x + x, self.panel.y + y)
  else
    self:set_position(x, y)
  end
end

function Label:draw(color, z_index)
  if not self.visible then return end

  color = color or {1, 1, 1}
  local c = {}
  local base_color = self.enabled and self.color or self.disabled_text_color
  c[1] = color[1] * base_color[1]
  c[2] = color[2] * base_color[2]
  c[3] = color[3] * base_color[3]
  c[4] = (color[4] or 1) * (self.color[4] or 1)
  self.font:draw_text(self.text, self.x, self.y, z_index, c, self.scale)
end
