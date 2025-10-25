require("lib.index")

require("src.event_manager")
require("src.main_menu")
require("src.scene")

Game = {
  load = function()
    Game.controllers = {
      MainMenu.new(),
    }

    EventManager.listen("game_start", Game.on_start)
  end,
  update = function()
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
    }
  end
}
