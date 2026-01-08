require("src.iso_game_object")
require("src.cache.item")

Item = setmetatable({}, IsoGameObject)
Item.__index = Item

function Item.new(id, col, row, layer)
  local data = ItemCache.fetch(id)

  local self = IsoGameObject.new(col, row, layer, ITEM_SIZE, ITEM_SIZE, ITEM_SIZE, data.img_or_path, data.img_gap)
  setmetatable(self, Item)
  self.id = id
  self.body:setActive(false)

  return self
end

function Item:update() end
