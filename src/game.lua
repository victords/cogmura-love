require("lib.index")

Game = {
  load = function()
  end,
  update = function()
  end,
  draw = function()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 10, 10, 100, 100)
    love.graphics.setColor(1, 1, 1)
  end,
  toggle_gamepad = function(enabled)
    print("gamepad " .. (enabled and "enabled" or "disabled"))
  end,
}
