Tileset = {}

function Tileset.new(path, cols, rows)
  local self = setmetatable({}, Tileset)
  self.tile_count = cols * rows

  local image = love.graphics.newImage(path)
  local img_width = image:getWidth()
  local img_height = image:getHeight()
  self.tile_width = math.floor(img_width / cols)
  self.tile_height = math.floor(img_height / rows)
  self.tiles = {}
  for i = 1, self.tile_count do
    self.tiles[i] = Image.new(image, ((i - 1) % cols) * self.tile_width, math.floor((i - 1) / cols) * self.tile_height, self.tile_width, self.tile_height)
  end

  return self
end

function Tileset:__index(value)
  if type(value) == "number" then
    return self.tiles[value]
  end

  return Tileset[value]
end
