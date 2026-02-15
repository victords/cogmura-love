require("lib.index")

require("src.constants")
require("src.event_manager")
require("src.in_game_ui")
require("src.main_menu")
require("src.player_stats")
require("src.scene")
require("src.battle")

FADE_DURATION = 20

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
    Game.scene_cache = {}
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
    if Game.fade_timer then
      Game.fade_timer = Game.fade_timer + 1
      if Game.fade_timer == FADE_DURATION then
        if Game.on_fade_out_finish then
          Game.on_fade_out_finish()
          Game.on_fade_out_finish = nil
          Game.fade_timer = 0
        else
          EventManager.trigger("fade_finish")
          Game.fade_timer = nil
        end
      end
      return
    end

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

      if Game.fade_timer then
        local alpha = Game.fade_timer / FADE_DURATION
        if Game.on_fade_out_finish == nil then
          alpha = 1 - alpha
        end
        Window.draw_rectangle(0, 0, UI_Z_INDEX + 1, SCREEN_WIDTH, SCREEN_HEIGHT, {0, 0, 0, alpha})
      end
    end)
  end,
  toggle_gamepad = function(enabled)
    print("gamepad " .. (enabled and "enabled" or "disabled"))
  end,
  on_start = function()
    Game.scene = Scene.new(1)
    table.insert(Game.scene_cache, Game.scene)
    Game.controllers = {
      Game.scene,
      InGameUi.new(Game.player_stats)
    }
    Game.fade_timer = 0
  end,
  on_battle_start = function(initiator)
    local battle = Battle.new(Game.player_stats, Game.scene.map, Game.scene.battle_spawn_points, initiator)
    table.insert(Game.controllers, battle)
  end,
  on_battle_finish = function()
    remove_controllers(Battle)
  end,
  on_scene_exit = function(dest_scene, dest_entrance)
    Game.on_fade_out_finish = function()
      Game.scene:deactivate(true)
      remove_controllers(Scene)
      local scene = Utils.find(Game.scene_cache, function(s) return s.index == dest_scene end)
      if scene then
        scene:activate(dest_entrance)
        Game.scene = scene
      else
        Game.scene = Scene.new(dest_scene, dest_entrance)
        table.insert(Game.scene_cache, Game.scene)
        if #Game.scene_cache > 3 then
          Game.scene_cache[1]:clean()
          table.remove(Game.scene_cache, 1)
        end
      end
      table.insert(Game.controllers, Game.scene)
    end
    Game.fade_timer = 0
  end
}
