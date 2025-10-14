DropDownList = setmetatable({}, Component)
DropDownList.__index = DropDownList

function DropDownList.new(x, y, options, on_changed)
  local self = Component.new(x, y, 0, 0, options)
  setmetatable(self, DropDownList)

  self.values = options.values or {'empty'}
  self.value = self.values[options.selected_index or 1]

  local btn_options = Utils.clone(options)
  btn_options.text = self.value
  btn_options.params = self
  self.buttons = {
    Button.new(x, y, btn_options, function(ddl) ddl:toggle() end)
  }

  self.w = self.buttons[1].w
  self.h = self.buttons[1].h
  self.anchor, self.x, self.y = Utils.check_anchor(self.anchor, x, y, self.w, self.h)

  local v_btn_options = Utils.clone(options)
  v_btn_options.img_path = options.opt_img_path
  for i, v in ipairs(self.values) do
    v_btn_options.text = v
    v_btn_options.params = {self, v}
    table.insert(self.buttons, Button.new(0, 0, v_btn_options, function(params)
      params[1]:set_value(params[2])
      params[1]:toggle()
    end))
  end
  for i, b in ipairs(self.buttons) do
    if i > 1 then
      b:set_position(self.x, self.y + self.h + (i - 2) * self.buttons[2].h)
      b.visible = false
    end
  end

  self.max_h = self.h + (#self.buttons - 1) * self.buttons[2].h
  self.on_changed = on_changed

  return self
end

function DropDownList:update()
  if not (self.enabled and self.visible) then return end

  if self.open and Mouse.pressed("left") and not Mouse.over(self.x, self.y, self.w, self.max_h) then
    self:toggle()
    return
  end

  for _, b in ipairs(self.buttons) do
    b:update()
  end
end

function DropDownList:set_value(value)
  for _, v in ipairs(self.values) do
    if v == value then
      local prev_value = self.value
      self.value = value
      self.buttons[1]:set_text(value)
      if self.on_changed then self.on_changed(prev_value, value) end
      break
    end
  end
end

function DropDownList:set_enabled(value)
  if self.open then self:toggle() end
  self.buttons[1]:set_enabled(value)
  self.enabled = value
end

function DropDownList:set_position(x, y)
  self.x = x
  self.y = y
  self.buttons[1]:set_position(x, y)
  for i, b in ipairs(self.buttons) do
    if i > 1 then
      b:set_position(x, y + self.h + (i - 2) * self.buttons[2].h)
    end
  end
end

function DropDownList:draw(color)
  if not self.visible then return end

  for _, b in ipairs(self.buttons) do
    b:draw(color)
  end
end

-- private
function DropDownList:toggle()
  self.open = not self.open
  for i, b in ipairs(self.buttons) do
    if i > 1 then b.visible = self.open end
  end
end
