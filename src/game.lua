require("lib.index")

require("src.main_menu")

Game = {
  load = function()
    Game.controllers = {
      MainMenu.new(),
    }
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
}
