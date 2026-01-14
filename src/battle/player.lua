require("src.battle.combatant")

BattlePlayer = setmetatable({}, Combatant)
BattlePlayer.__index = BattlePlayer

function BattlePlayer.new(stats, col, row, layer, map)
  local self = Combatant.new(stats, col, row, layer, 12, 12, PHYSICS_UNIT, "sprite/player", Vector.new(0, -8), map)
  setmetatable(self, BattlePlayer)
  self.is_player = true

  self.action_buttons = {
    { text = "attack", x = 0, y = 0, w = 150, h = 35, action = function() self:start_target_selection({type = "attack", value = stats.str}) end },
    { text = "item", x = 0, y = 40, w = 150, h = 35, action = function() self:start_item_selection() end },
    { text = "flee", x = 0, y = 80, w = 150, h = 35, action = function() self.on_action_perform({type = "flee"}) end }
  }
  self.item_buttons = {}
  local index = 0
  for item_id, amount in pairs(stats.inventory) do
    local item = ItemCache.fetch(item_id)
    table.insert(self.item_buttons, {
      text = ItemCache.name_map[item_id],
      x = 150, y = index * 40, w = 150, h = 35,
      action = function()
        self:start_target_selection({type = "item", item = item})
      end
    })
    index = index + 1
  end
  self.button_list = self.action_buttons
  self.button_index = 1
  self.font = Res.font("font", 24)

  return self
end

function BattlePlayer:start_target_selection(action)
  local targets = self.on_action_select(action)
  self.button_index = 1
  self.button_list = Utils.map(targets, function(target)
    local action_with_target = Utils.clone(action)
    action_with_target.target = target
    local target_pos = target:get_mass_center()
    if target ~= self then
      target_pos = target_pos + Vector.new(-PHYSICS_UNIT, PHYSICS_UNIT)
    end
    return {
      x = target.screen_x - 20,
      y = target.screen_y - 80,
      w = 40,
      h = 40,
      action = function()
        self:set_moving_towards(target_pos, function()
          self.on_action_perform(action_with_target)
          self:set_moving_to_start()
        end)
      end
    }
  end)
end

function BattlePlayer:start_item_selection()
  if #self.item_buttons == 0 then return end

  self.button_list = self.item_buttons
  self.button_index = 1
end

function BattlePlayer:end_turn()
  Combatant.end_turn(self)
  self.button_list = self.action_buttons
  self.button_index = 1
end

function BattlePlayer:update()
  if not self.active then return end

  if self.state == "idle" then
    if KB.pressed("down") then
      local index = self.button_index + 1
      if index > #self.button_list then
        index = 1
      end
      self.button_index = index
    elseif KB.pressed("up") then
      local index = self.button_index - 1
      if index == 0 then
        index = #self.button_list
      end
      self.button_index = index
    elseif KB.pressed("return") then
      self.button_list[self.button_index].action()
    end
  elseif self.state == "moving" then
    self:move_towards_target()
  end
end

function BattlePlayer:draw(map)
  Combatant.draw(self, map)

  if not self.active then return end
  if self.state == "moving" then return end

  for i, b in ipairs(self.button_list) do
    Window.draw_rectangle(b.x, b.y, UI_Z_INDEX, b.w, b.h, i == self.button_index and {0.5, 0.5, 0.5} or {0.75, 0.75, 0.75})
    if b.text then
      self.font:draw_text(b.text, b.x, b.y, UI_Z_INDEX, {0, 0, 0})
    end
  end
end
