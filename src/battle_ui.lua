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
      { text = "attack", x = 0, y = 0, action = function() self:start_target_selection("attack") end },
      { text = "flee", x = 0, y = 40, action = function() self:start_action("flee") end }
    },
    targets = Utils.map(battle.enemies, function(enemy)
      return { x = enemy.screen_x - 20, y = enemy.screen_y - 100, action = function() self:confirm_target() end }
    end)
  }
  self.button_list = self.buttons.base
  self.button_index = 1
  self.font = Res.font("font", 24)
  self.active = true

  self.health_bars = {
    ProgressBar.new(battle.player.screen_x - 40, battle.player.screen_y - 100, {w = 80, h = 10, bg_color = {1, 0, 0}, fg_color = {0, 1, 0}, max_value = player_stats.max_hp, value = player_stats.hp})
  }
  for _, enemy in ipairs(battle.enemies) do
    table.insert(
      self.health_bars,
      ProgressBar.new(enemy.screen_x - 40, enemy.screen_y - 100, {w = 80, h = 10, bg_color = {1, 0, 0}, fg_color = {0, 1, 0}, max_value = enemy.stats.max_hp, value = enemy.stats.hp})
    )
  end

  return self
end

function BattleUi:start_target_selection(action)
  self.action = action
  self.button_list = self.buttons.targets
  self.button_index = 1
end

function BattleUi:start_action(action, ...)
  self.battle:on_action_start(action, ...)
  self.active = false
end

function BattleUi:confirm_target()
  self:start_action(self.action, self.button_index)
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
  for _, b in ipairs(self.health_bars) do
    b:draw(nil, UI_Z_INDEX)
  end

  if not self.active then return end

  local is_base = self.button_list == self.buttons.base
  for i, b in ipairs(self.buttons.base) do
    Window.draw_rectangle(b.x, b.y, UI_Z_INDEX, 150, 35, is_base and i == self.button_index and {0.5, 0.5, 0.5} or {0.75, 0.75, 0.75})
    self.font:draw_text(b.text, b.x, b.y, UI_Z_INDEX, {0, 0, 0})
  end
  if not is_base then
    for i, b in ipairs(self.button_list) do
      Window.draw_rectangle(b.x, b.y, UI_Z_INDEX, 40, 40, i == self.button_index and {0.5, 0.5, 0.5} or  {0.75, 0.75, 0.75})
    end
  end
end
