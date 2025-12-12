require("lib.index")

require("src.event_manager")
require("src.in_game_ui")
require("src.main_menu")
require("src.player_stats")
require("src.scene")
require("src.primitive_image")

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
    image = PrimitiveImage.new(
      40, 40,
      {type = "circle", x = 20, y = 20, radius = 20, color = {1, 0, 0}},
      {type = "rectangle", x = 4, y = 4, w = 8, h = 8, color = {0, 0, 0}},
      {type = "rectangle", x = 28, y = 4, w = 8, h = 8, color = {0, 0, 1}}
    )
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
      image:draw(0, 100)
    end)
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
