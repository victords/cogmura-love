require("src.iso_game_object")
require("src.stats")

Enemy = setmetatable({}, IsoGameObject)
Enemy.__index = Enemy

Enemy.ids = {
  "bruk",
}
Enemy.cache = {}

function Enemy.new(id, col, row, layer)
  id = tonumber(id)

  local size = nil
  local img_or_path = nil
  local img_gap = nil
  local cache = Enemy.cache[id]

  if cache then
    size = cache.size
    img_or_path = cache.img_or_path
    img_gap = cache.img_gap
  else
    local data = Utils.split(love.filesystem.read("data/enemy/" .. Enemy.ids[id] .. ".txt"), "\n")
    local attrs = Utils.split(data[1], ",")

    size = tonumber(attrs[7])
    img_gap = Vector.new(attrs[8] and tonumber(attrs[8]) or 0, attrs[9] and tonumber(attrs[9]) or 0)
    if data[2]:sub(1, 1) == "!" then
      local shapes_data = Utils.split(data[2], "!")
      local shapes = {}
      local img_width = nil
      local img_height = nil
      for _, shape_data in ipairs(shapes_data) do
        local shape_attrs = Utils.map(Utils.split(shape_data:sub(2), ","), function(s) return tonumber(s) end)
        if shape_data:sub(1, 1) == "r" then
          color = {shape_attrs[5], shape_attrs[6], shape_attrs[7]}
          table.insert(shapes, { type = "rectangle", x = shape_attrs[1], y = shape_attrs[2], w = shape_attrs[3], h = shape_attrs[4], color = color })
        elseif shape_data:sub(1, 1) == "c" then
          color = {shape_attrs[4], shape_attrs[5], shape_attrs[6]}
          table.insert(shapes, { type = "circle", x = shape_attrs[1], y = shape_attrs[2], radius = shape_attrs[3] })
        elseif shape_data:sub(1, 1) == "s" then
          img_width = shape_attrs[1]
          img_height = shape_attrs[2]
        end
      end
      img_or_path = PrimitiveImage.new(img_width, img_height, unpack(shapes))
    else
      img_or_path = data[2]
    end

    cache = {
      max_hp = tonumber(attrs[1]),
      max_mp = tonumber(attrs[2]),
      str = tonumber(attrs[3]),
      def = tonumber(attrs[4]),
      exp = tonumber(attrs[5]),
      money = tonumber(attrs[6]),
      size = size,
      img_or_path = img_or_path,
      img_gap = img_gap
    }
    Enemy.cache[id] = cache
  end

  local self = IsoGameObject.new(col, row, layer, size, size, ENEMY_HEIGHT, img_or_path, img_gap)
  setmetatable(self, Enemy)
  self.stats = Stats.new(cache.max_hp, cache.max_mp, cache.str, cache.def, cache.exp, cache.money)

  return self
end
