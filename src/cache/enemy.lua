EnemyCache = {
  cache = {},
  name_map = {
    "bruk",
  },
  fetch = function(id)
    if EnemyCache.cache[id] == nil then
      local data = Utils.split(love.filesystem.read("data/enemy/" .. EnemyCache.name_map[id] .. ".txt"), "\n")
      local attrs = Utils.split(data[1], ",")
      local size = tonumber(attrs[7])
      local img_gap = Vector.new(attrs[8] and tonumber(attrs[8]) or 0, attrs[9] and tonumber(attrs[9]) or 0)
      local img_or_path = data[2]:sub(1, 1) == "!" and PrimitiveImage.parse(data[2]) or data[2]

      EnemyCache.cache[id] = {
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
    end

    return EnemyCache.cache[id]
  end
}
