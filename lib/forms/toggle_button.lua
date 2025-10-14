ToggleButton = setmetatable({}, Button)
ToggleButton.__index = ToggleButton

function ToggleButton.new(x, y, options, action)
  local tb_options = Utils.clone(options)
  tb_options.cols = 2
  local self = Button.new(x, y, tb_options, action)
  setmetatable(self, ToggleButton)
  self.checked = options.checked or false
  return self
end

function ToggleButton:set_enabled(value)
  self.enabled = value
  self.state = "up"
  self.img_index = value and 1 or 7
  if self.checked then self.img_index = self.img_index + 1 end
end

function ToggleButton:set_checked(value)
  if value ~= self.checked then
    self.action(value, self.params)
    self.checked = value
  end
end

function ToggleButton:click()
  self:set_checked(not self.checked)
end

function ToggleButton:update()
  if not (self.enabled and self.visible) then return end

  Button.update(self)
  if self.checked then
    self.img_index = self.img_index * 2
  else
    self.img_index = self.img_index * 2 - 1
  end
end
