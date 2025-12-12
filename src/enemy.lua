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
  local img_path = nil
  local img_gap = nil
  local cache = Enemy.cache[id]

  if cache then
    size = cache.size
    img_path = cache.img_path
    img_gap = cache.img_gap
  else
    local data = Utils.split(love.filesystem.read("data/enemy/" .. Enemy.ids[id] .. ".txt"), "\n")
    local attrs = Utils.split(data[1], ",")
    size = tonumber(attrs[7])
    img_path = "sprite/" .. data[2]
    img_gap = Vector.new(attrs[8] and tonumber(attrs[8]) or 0, attrs[9] and tonumber(attrs[9]) or 0)
    cache = {
      max_hp = tonumber(attrs[1]),
      max_mp = tonumber(attrs[2]),
      str = tonumber(attrs[3]),
      def = tonumber(attrs[4]),
      exp = tonumber(attrs[5]),
      money = tonumber(attrs[6]),
      size = size,
      img_path = img_path,
      img_gap = img_gap
    }
    Enemy.cache[id] = cache
  end

  local self = IsoGameObject.new(col, row, layer, size, size, ENEMY_HEIGHT, img_path, img_gap)
  setmetatable(self, Enemy)
  self.stats = Stats.new(cache.max_hp, cache.max_mp, cache.str, cache.def, cache.exp, cache.money)

  return self
end
