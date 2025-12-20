require("src.iso_game_object")
require("src.cache.enemy")

Enemy = setmetatable({}, IsoGameObject)
Enemy.__index = Enemy

FOLLOW_RANGE = 3 * PHYSICS_UNIT
VERT_FOLLOW_RANGE = PHYSICS_UNIT
SPEED = 1.5 * PHYSICS_UNIT

function Enemy.new(id, col, row, layer)
  local data = EnemyCache.fetch(id)

  local self = IsoGameObject.new(col, row, layer, data.size, data.size, ENEMY_HEIGHT, data.img_or_path, data.img_gap)
  setmetatable(self, Enemy)
  self.id = id
  self.active = true

  return self
end

function Enemy:activate()
  self.active_timer = 120
  self.body:setActive(true)
end

function Enemy:deactivate()
  self.active = false
  self.body:setLinearVelocity(0, 0)
  self.body:setActive(false)
end

function Enemy:update(player_character)
  if self.active_timer then
    self.active_timer = self.active_timer - 1
    if self.active_timer == 0 then
      self.active_timer = nil
      self.active = true
    end
  end
  if not self.active then return end

  if self:is_in_contact_with(player_character) then
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
