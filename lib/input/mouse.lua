Mouse = {
  cur_down = {},
  prev_down = {},
  dbl_click = {},
  dbl_click_timer = {},
  double_click_delay = 8
}
local button_number_to_name = {"left", "right", "middle"}
for _, v in pairs(button_number_to_name) do
  Mouse.cur_down[v] = false
end

function Mouse.update()
  Mouse.click_captured = false
  Mouse.x = math.floor((love.mouse.getX() - Window.offset_x) / Window.scale)
  Mouse.y = math.floor((love.mouse.getY() - Window.offset_y) / Window.scale)
  for i, v in ipairs(button_number_to_name) do
    Mouse.prev_down[v] = Mouse.cur_down[v]
    Mouse.cur_down[v] = love.mouse.isDown(i)
    Mouse.dbl_click[v] = false

    if Mouse.dbl_click_timer[v] then
      if Mouse.dbl_click_timer[v] < Mouse.double_click_delay then
        Mouse.dbl_click_timer[v] = Mouse.dbl_click_timer[v] + 1
      else
        Mouse.dbl_click_timer[v] = nil
      end
    end

    if Mouse.cur_down[v] then
      if Mouse.dbl_click_timer[v] then Mouse.dbl_click[v] = true end
      Mouse.dbl_click_timer[v] = nil
    elseif Mouse.prev_down[v] then
      Mouse.dbl_click_timer[v] = 0
    end
  end
end

function Mouse.down(button_name)
  return Mouse.cur_down[button_name]
end

function Mouse.pressed(button_name)
  return Mouse.cur_down[button_name] and not Mouse.prev_down[button_name]
end

function Mouse.released(button_name)
  return Mouse.prev_down[button_name] and not Mouse.cur_down[button_name]
end

function Mouse.double_clicked(name)
  return Mouse.dbl_click[name]
end

function Mouse.over(x, y, w, h)
  if getmetatable(x) == Rectangle then
    return Mouse.x >= x.x and Mouse.x < x.x + x.w and Mouse.y >= x.y and Mouse.y < x.y + x.h
  end

  return Mouse.x >= x and Mouse.x < x + w and Mouse.y >= y and Mouse.y < y + h
end
