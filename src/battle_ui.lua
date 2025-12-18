BattleUi = {}
BattleUi.__index = BattleUi

function BattleUi.new(player_stats, battle)
  local self = setmetatable({}, BattleUi)
  self.player_stats = player_stats
  self.battle = battle
  self.battle.on_player_turn_start = function()
    self.active = true
  end

  self.buttons = {
    base = {
      { text = "attack", x = 0, y = 0, action = function() self:start_target_selection() end },
      { text = "flee", x = 0, y = 40, action = function() self:start_action("flee") end }
    },
    targets = Utils.map(battle.enemies, function(enemy)
      return { x = enemy.screen_x, y = enemy.screen_y - 40, action = function() self:confirm_target() end }
    end)
  }
  self.button_list = self.buttons.base
  self.button_index = 1
  self.font = Res.font("font", 24)
  self.active = true

  return self
end

function BattleUi:start_target_selection()
  self.button_list = self.buttons.targets
  self.button_index = 1
end

function BattleUi:start_action(action, ...)
  --self.battle:on_action_start(action, ...)
  self.active = false
end

function BattleUi:confirm_target()
  -- TODO
end

function BattleUi:update()
  if not self.active then return end

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
end

function BattleUi:draw()
  -- draw player and enemy stats

  if not self.active then return end

  local is_base = self.button_list == self.buttons.base
  for i, b in ipairs(self.buttons.base) do
    Window.draw_rectangle(b.x, b.y, UI_Z_INDEX, 150, 35, is_base and i == self.button_index and {0.5, 0.5, 0.5} or {0.75, 0.75, 0.75})
    self.font:draw_text(b.text, b.x, b.y, UI_Z_INDEX)
  end
  if not is_base then
    for i, b in ipairs(self.button_list) do
      Window.draw_rectangle(b.x, b.y, UI_Z_INDEX, 35, 35, i == self.button_index and {0.5, 0.5, 0.5} or  {0.75, 0.75, 0.75})
    end
  end
end
