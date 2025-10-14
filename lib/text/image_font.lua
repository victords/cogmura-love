ImageFont = setmetatable({}, Font)
ImageFont.__index = ImageFont

function ImageFont.new(path, characters, char_spacing)
  local self = setmetatable({}, ImageFont)
  self.source = love.graphics.newImageFont(path, characters, char_spacing)
  self.height = self.source:getHeight()
  return self
end
