require("src.iso_game_object")
require("src.battle.health_bar")

Combatant = setmetatable({}, IsoGameObject)
Combatant.__index = Combatant

MOVE_SPEED = 10 * PHYSICS_UNIT

function Combatant.new(stats, col, row, layer, width, depth, height, img_path, img_gap, map)
  local self = IsoGameObject.new(col, row, layer, width, depth, height, img_path, img_gap)
  setmetatable(self, Combatant)
  self.stats = stats
  local screen_pos = map:get_screen_pos(col, row) + Vector.new(HALF_TILE_WIDTH, HALF_TILE_HEIGHT - layer * ISO_UNIT)
  self.screen_x = screen_pos.x
  self.screen_y = screen_pos.y
  self.start_pos = self:get_mass_center()
  self.health_bar = HealthBar.new(stats, self)
  self.active = false
  self.state = "idle"

  self.body:setActive(false)
  return self
end

function Combatant:start_turn()
  self.active = true
  self.body:setActive(true)
end

function Combatant:end_turn()
  self.active = false
  self.state = "idle"
  self.body:setLinearVelocity(0, 0)
  self.body:setActive(false)
end

function Combatant:set_moving_towards(target_pos, on_finish)
  self.body:setActive(true)
  self.target_pos = target_pos
  self.on_move_finish = on_finish
  self.state = "moving"
end

function Combatant:set_moving_to_start()
  self:set_moving_towards(self.start_pos, function()
    self:end_turn()
    self.on_action_finish()
  end)
end

function Combatant:move_towards_target()
  self:move_free(self.target_pos, MOVE_SPEED)
  local x, y = self.body:getLinearVelocity()
  if x == 0 and y == 0 then
    self.body:setActive(false)
    self.target_pos = nil
    self.on_move_finish()
  end
end

function Combatant:draw(map)
  IsoGameObject.draw(self, map)
  self.health_bar:draw()
end
