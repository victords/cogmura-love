require("src.game")

function love.load()
  Window.init()
  Game.load()
end

function love.update(dt)
  Mouse.update()
  Game.update()
end

function love.draw()
  Window.draw(function ()
    Game.draw()
  end)
end

function love.joystickadded()
  Game.toggle_gamepad(true)
end

function love.joystickremoved()
  if love.joystick.getJoystickCount() == 0 then
    Game.toggle_gamepad(false)
  end
end
