require("lib.index")

require("src.event_manager")
require("src.in_game_ui")
require("src.main_menu")
require("src.player_stats")
require("src.scene")

Game = {
  load = function()
    Game.player_stats = PlayerStats.load("10,5,1,0,0,0")
    Game.controllers = {
      MainMenu.new(),
    }

    EventManager.listen("game_start", Game.on_start)
  end,
  update = function()
    KB.update()
    Mouse.update()

    if KB.pressed("f4") then
      Window.toggle_fullscreen()
    end

    for _, controller in ipairs(Game.controllers) do
      controller:update()
    end
  end,
  draw = function()
    for _, controller in ipairs(Game.controllers) do
      controller:draw()
    end
  end,
  toggle_gamepad = function(enabled)
    print("gamepad " .. (enabled and "enabled" or "disabled"))
  end,
  on_start = function()
    Game.controllers = {
      Scene.new(),
      InGameUi.new(Game.player_stats)
    }
  end
}
