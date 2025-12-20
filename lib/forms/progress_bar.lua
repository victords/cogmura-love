ProgressBar = setmetatable({}, Component)
ProgressBar.__index = ProgressBar

function ProgressBar.new(x, y, options)
  local scale = options.scale or 1
  local bg_img, bg_color, w, h
  if options.bg_img_path then
    bg_img = Res.img(options.bg_img_path)
    w = scale * bg_img.width
    h = scale * bg_img.height
  else
    bg_color = options.bg_color or {0, 0, 0}
    w = options.w or 100
    h = options.h or 30
  end

  local self = Component.new(x, y, w, h, options)
  setmetatable(self, ProgressBar)
  self.scale = scale
  self.bg_img = bg_img
  self.bg_color = bg_color
  self.max_value = options.max_value or 100
  self.value = options.value or self.max_value
  self.format = options.format
  self.fg_margin_x = options.fg_margin_x or 0
  self.fg_margin_y = options.fg_margin_y or 0
  if options.fg_img_path then
    self.fg_img_path = options.fg_img_path
    self.fg_img_full_path = Res.prefix .. Res.img_prefix .. self.fg_img_path .. "." .. (options.fg_img_extension or "png")
    self.fg_img = Res.img(options.fg_img_path)
    self.fg_img_width = Utils.round(scale * self.fg_img.width)
    self:update_fg_img()
  else
    self.fg_color = options.fg_color or {1, 1, 1}
  end

  return self
end

function ProgressBar:set_value(value)
  self.value = value
  if self.value > self.max_value then self.value = self.max_value end
  if self.value < 0 then self.value = 0 end
  if self.fg_img then self:update_fg_img() end
end

function ProgressBar:set_percentage(pct)
  self:set_value(Utils.round(pct * self.max_value))
end

function ProgressBar:increase(amount)
  self:set_value(self.value + (amount or 1))
end

function ProgressBar:decrease(amount)
  self:set_value(self.value - (amount or 1))
end

function ProgressBar:draw(color, z_index)
  if not self.visible then return end

  color = color or {1, 1, 1}
  if self.bg_img then
    self.bg_img:draw(self.x, self.y, z_index, self.scale, self.scale, nil, color)
  else
    local c = {self.bg_color[1] * color[1], self.bg_color[2] * color[2], self.bg_color[3] * color[3]}
    Window.draw_rectangle(self.x, self.y, z_index, self.w, self.h, c)
  end

  local fg_width = Utils.round(self.value / self.max_value * (self.w - 2 * self.fg_margin_x))
  local x0 = self.x + self.fg_margin_x
  local y = self.y + self.fg_margin_y
  if self.fg_img then
    local end_x = x0
    for x = 0, fg_width - self.fg_img_width, self.fg_img_width do
      self.fg_img:draw(x0 + x, y, z_index, self.scale, self.scale, nil, color)
      end_x = end_x + self.fg_img_width
    end
    if self.fg_img_end then
      self.fg_img_end:draw(end_x, y, z_index, self.scale, self.scale, nil, color)
    end
  else
    local c = {self.fg_color[1] * color[1], self.fg_color[2] * color[2], self.fg_color[3] * color[3]}
    Window.draw_rectangle(x0, y, z_index, fg_width, self.h - 2 * self.fg_margin_y, c)
  end

  if self.font then
    local c = {self.text_color[1] * color[1], self.text_color[2] * color[2], self.text_color[3] * color[3]}
    local text = self.format == "%" and (tostring(Utils.round(self.value / self.max_value * 100)) .. "%") or (tostring(self.value) .. "/" .. tostring(self.max_value))
    self.font:draw_text_rel(text, self.x + self.w / 2, self.y + self.h / 2, z_index, 0.5, 0.5, c, self.scale)
  end
end

--private
function ProgressBar:update_fg_img()
  local fg_width = Utils.round(self.value / self.max_value * (self.w - 2 * self.fg_margin_x))
  local end_width = fg_width % self.fg_img_width
  if end_width == 0 then
    self.fg_img_end = nil
  else
    self.fg_img_end = Image.new(self.fg_img_full_path, 0, 0, end_width / self.scale, self.fg_img.height)
  end
end
