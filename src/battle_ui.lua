BattleUi = {}
BattleUi.__index = BattleUi

function BattleUi.new(battle)
  local self = setmetatable({}, BattleUi)
  self.battle = battle
  self.battle.on_player_turn_start = function()
    self.active = true
  end

  self.buttons = {
    base = {
      { text = "attack", x = 0, y = 0, w = 150, h = 35, action = function() self:start_target_selection("attack") end },
      { text = "flee", x = 0, y = 40, w = 150, h = 35, action = function() self:start_action("flee") end }
    },
    targets = Utils.map(battle.enemies, function(enemy)
      return { x = enemy.screen_x - 20, y = enemy.screen_y - 80, w = 40, h = 40, action = function() self:confirm_target() end }
    end)
  }
  self.button_list = self.buttons.base
  self.button_index = 1
  self.font = Res.font("font", 24)
  self.active = true

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
  if not self.active then return end

  for i, b in ipairs(self.button_list) do
    Window.draw_rectangle(b.x, b.y, UI_Z_INDEX, b.w, b.h, i == self.button_index and {0.5, 0.5, 0.5} or {0.75, 0.75, 0.75})
    if b.text then
      self.font:draw_text(b.text, b.x, b.y, UI_Z_INDEX, {0, 0, 0})
    end
  end
end
