require("lib.index")

require("src.constants")
require("src.event_manager")
require("src.in_game_ui")
require("src.main_menu")
require("src.player_stats")
require("src.scene")
require("src.battle")

local function remove_controllers(...)
  local classes = {...}
  for i = #Game.controllers, 1, -1 do
    for _, class in ipairs(classes) do
      if getmetatable(Game.controllers[i]) == class then
        table.remove(Game.controllers, i)
      end
    end
  end
end

Game = {
  load = function()
    Window.init(false, 1280, 720, SCREEN_WIDTH, SCREEN_HEIGHT)
    Physics.gravity.y = 0
    Physics.set_engine("love")

    Game.player_stats = PlayerStats.load("10,5,1,0,0,0")
    Game.controllers = {
      MainMenu.new(),
    }

    EventManager.listen("game_start", Game.on_start)
    EventManager.listen("battle_start", Game.on_battle_start)
    EventManager.listen("battle_finish", Game.on_battle_finish)
    EventManager.listen("scene_exit", Game.on_scene_exit)

    math.randomseed(os.time())
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
    Game.scene = Scene.new(1)
    Game.controllers = {
      Game.scene,
      InGameUi.new(Game.player_stats)
    }
  end,
  on_battle_start = function(initiator)
    local battle = Battle.new(Game.player_stats, Game.scene.map, Game.scene.battle_spawn_points, initiator)
    table.insert(Game.controllers, battle)
  end,
  on_battle_finish = function()
    remove_controllers(Battle)
  end,
  on_scene_exit = function(dest_scene, dest_entrance)
    remove_controllers(Scene)
    Game.scene = Scene.new(dest_scene, dest_entrance)
    table.insert(Game.controllers, Game.scene)
  end
}
