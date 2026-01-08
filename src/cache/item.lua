ItemCache = {
  cache = {},
  name_map = {
    "pakia",
  },
  fetch = function(id)
    if ItemCache.cache[id] == nil then
      local data = Utils.split(love.filesystem.read("data/item/" .. ItemCache.name_map[id] .. ".txt"), "\n")
      local attrs = Utils.split(data[1], ",")
      local img_gap = Vector.new(attrs[5] and tonumber(attrs[5]) or 0, attrs[6] and tonumber(attrs[6]) or 0)

      if data[2]:sub(1, 1) == "!" then
        img_or_path = PrimitiveImage.parse(data[2])
      else
        img_or_path = data[2]
      end

      ItemCache.cache[id] = {
        type = attrs[1],
        target = attrs[2],
        value = tonumber(attrs[3]),
        turns = tonumber(attrs[4]),
        img_or_path = img_or_path,
        img_gap = img_gap
      }
    end

    return ItemCache.cache[id]
  end
}
