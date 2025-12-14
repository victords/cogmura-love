require("src.iso_game_object")
require("src.stats")

Enemy = setmetatable({}, IsoGameObject)
Enemy.__index = Enemy

Enemy.ids = {
  "bruk",
}
Enemy.cache = {}

FOLLOW_RANGE = 3 * PHYSICS_UNIT
VERT_FOLLOW_RANGE = PHYSICS_UNIT
SPEED = 1.5 * PHYSICS_UNIT

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
        local s_a = Utils.map(Utils.split(shape_data:sub(2), ","), function(s) return tonumber(s) end)
        if shape_data:sub(1, 1) == "r" then
          color = {s_a[5], s_a[6], s_a[7]}
          table.insert(shapes, { type = "rectangle", x = s_a[1], y = s_a[2], w = s_a[3], h = s_a[4], color = color })
        elseif shape_data:sub(1, 1) == "c" then
          color = {s_a[4], s_a[5], s_a[6]}
          table.insert(shapes, { type = "circle", x = s_a[1], y = s_a[2], radius = s_a[3], color = color })
        elseif shape_data:sub(1, 1) == "a" then
          color = {s_a[6], s_a[7], s_a[8]}
          table.insert(shapes, { type = "arc", x = s_a[1], y = s_a[2], radius = s_a[3], a1 = s_a[4], a2 = s_a[5], color = color })
        elseif shape_data:sub(1, 1) == "s" then
          img_width = s_a[1]
          img_height = s_a[2]
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

  local self = IsoGameObject.new(col, row, layer, size, size, ENEMY_HEIGHT, img_or_path, img_gap, nil, nil)
  setmetatable(self, Enemy)
  self.stats = Stats.new(cache.max_hp, cache.max_mp, cache.str, cache.def, cache.exp, cache.money)
  self.active = true

  return self
end

function Enemy:update(player_character)
  if self:is_in_contact_with(player_character) then
    self.active = false
    self.body:setActive(false)
    EventManager.trigger("battle_start", self)
    return
  end

  local d = self:get_mass_center():distance(player_character:get_mass_center())
  local d_z = player_character.z - self.z
  if d <= FOLLOW_RANGE and d > 0 and math.abs(d_z) <= VERT_FOLLOW_RANGE then
    local d_x = player_character:get_x() - self:get_x()
    local d_y = player_character:get_y() - self:get_y()
    local speed = Vector.new(SPEED * d_x / d, SPEED * d_y / d)
    self:move(speed, nil, nil, true)
  else
    self.body:setLinearVelocity(0, 0)
  end
end
