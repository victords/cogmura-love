require("src.primitive_image")

IsoGameObject = setmetatable({}, GameObject)
IsoGameObject.__index = IsoGameObject

function IsoGameObject.new(col, row, layer, width, depth, height, img_or_path, img_gap, cols, rows, physics_options)
  local img = nil
  if getmetatable(img_or_path) == PrimitiveImage then
    img = img_or_path
    img_or_path = nil
  end
  local self = GameObject.new((col + 0.5) * PHYSICS_UNIT - width * 0.5, (row + 0.5) * PHYSICS_UNIT - depth * 0.5, width, depth, img_or_path, img_gap, cols, rows, physics_options)
  setmetatable(self, IsoGameObject)
  self.z = layer * PHYSICS_UNIT
  self.height = height
  self.img = self.img or img
  return self
end

function IsoGameObject:intersect(other)
  if not self:bounds():intersect(other:bounds()) then return false end

  return self.z + self.height > other.z and other.z + other.height > self.z
end

function IsoGameObject:get_layer()
  return math.floor(self.z / PHYSICS_UNIT)
end

function IsoGameObject:activate() end

function IsoGameObject:deactivate() end

function IsoGameObject:draw(map)
  local x = self:get_x() + self.w / 2
  local y = self:get_y() + self.h / 2
  local col = math.floor(x / PHYSICS_UNIT)
  local row = math.floor(y / PHYSICS_UNIT)
  local offset_x = x - col * PHYSICS_UNIT
  local offset_y = y - row * PHYSICS_UNIT
  local offset_x_ratio = offset_x / PHYSICS_UNIT
  local offset_y_ratio = offset_y / PHYSICS_UNIT
  local base_pos = map:get_screen_pos(col, row)
  local screen_x = base_pos.x + HALF_TILE_WIDTH * (1 + offset_x_ratio - offset_y_ratio)
  local screen_y = base_pos.y + HALF_TILE_HEIGHT * (offset_x_ratio + offset_y_ratio)
  local layer = math.floor(self.z / PHYSICS_UNIT)
  self.img:draw(
    Utils.round(screen_x - self.img.width / 2 + self.img_gap.x),
    Utils.round(screen_y - (self.z + self.height) / PHYSICS_UNIT * ISO_UNIT + self.img_gap.y),
    self.z_index or Utils.round((col + row + 2) * 10000 + layer * 100 + (offset_x_ratio + offset_y_ratio) * 50)
  )
end
