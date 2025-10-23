MainMenu = {}
MainMenu.__index = MainMenu

function MainMenu.new()
  local self = setmetatable({}, MainMenu)

  local font = Res.font("font", 24)
  self.buttons = {
    Button.new(0, -65, {w = 150, h = 30, font = font, text = "Play", anchor = "center"}),
    Button.new(0, -15, {w = 150, h = 30, font = font, text = "Options", anchor = "center"}),
    Button.new(0, 35, {w = 150, h = 30, font = font, text = "Exit", anchor = "center"}),
  }

  return self
end

function MainMenu:update()
  for _, button in ipairs(self.buttons) do
    button:update()
  end
end

function MainMenu:draw()
  for _, button in ipairs(self.buttons) do
    button:draw()
  end
end
