require("lib.index")

require("src.event_manager")
require("src.in_game_ui")
require("src.main_menu")
require("src.player_stats")
require("src.scene")
require("src.battle")
require("src.battle_ui")

Game = {
  load = function()
    Window.init(false, 1280, 720, 1920, 1080)
    Physics.gravity.y = 0
    Physics.set_engine("love")

    Game.player_stats = PlayerStats.load("10,5,1,0,0,0")
    Game.controllers = {
      MainMenu.new(),
    }

    EventManager.listen("game_start", Game.on_start)
    EventManager.listen("battle_start", Game.on_battle_start)
  end,
  update = function(dt)
    KB.update()
    Mouse.update()
    Physics.update(dt)

    if KB.pressed("f4") then
      Window.toggle_fullscreen()
    end

    for _, controller in ipairs(Game.controllers) do
      controller:update()
    end

    --print(love.timer.getFPS())
  end,
  draw = function()
    Window.draw(function ()
      for _, controller in ipairs(Game.controllers) do
        controller:draw()
      end
    end)
  end,
  toggle_gamepad = function(enabled)
    print("gamepad " .. (enabled and "enabled" or "disabled"))
  end,
  on_start = function()
    Game.scene = Scene.new()
    Game.controllers = {
      Game.scene,
      InGameUi.new(Game.player_stats)
    }
  end,
  on_battle_start = function(initiator)
    local battle = Battle.new(Game.scene.map, Game.scene.battle_spawn_points, initiator)
    table.insert(Game.controllers, battle)
    table.insert(Game.controllers, BattleUi.new(Game.player_stats, battle))
  end
}
