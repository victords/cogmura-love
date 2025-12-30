require("src.iso_game_object")

BattlePlayer = setmetatable({}, IsoGameObject)
BattlePlayer.__index = BattlePlayer

MOVE_SPEED = 5 * PHYSICS_UNIT

function BattlePlayer.new(stats, col, row, layer, map)
  local self = IsoGameObject.new(col, row, layer, 12, 12, PHYSICS_UNIT, "sprite/player", Vector.new(0, -8))
  setmetatable(self, BattlePlayer)
  self.stats = stats
  local screen_pos = map:get_screen_pos(col, row) + Vector.new(HALF_TILE_WIDTH, HALF_TILE_HEIGHT - layer * ISO_UNIT)
  self.screen_x = screen_pos.x
  self.screen_y = screen_pos.y
  self.start_pos = self:get_mass_center()
  self.health_bar = HealthBar.new(stats, self)

  self.body:setActive(false)
  return self
end

function BattlePlayer:move_towards(target_pos, on_finish, on_finish_arg)
  self.body:setActive(true)
  self.target_pos = target_pos
  self.on_move_finish = on_finish
  self.on_move_finish_arg = on_finish_arg
end

function BattlePlayer:move_to_start(on_finish, on_finish_arg)
  self:move_towards(self.start_pos, on_finish, on_finish_arg)
end

function BattlePlayer:update()
  if self.target_pos then
    -- animate

    self:move_free(self.target_pos, MOVE_SPEED)
    local x, y = self.body:getLinearVelocity()
    if x == 0 and y == 0 then
      self.body:setActive(false)
      self.target_pos = nil
      self.on_move_finish(self.on_move_finish_arg)
    end
  end
end

function BattlePlayer:draw(map)
  IsoGameObject.draw(self, map)
  self.health_bar:draw()
end
