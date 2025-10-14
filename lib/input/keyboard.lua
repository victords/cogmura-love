KB = {
  cur_down = {},
  prev_down = {},
  held_timer = {},
  held_delay = 30,
  held_interval = 5,
}
local KEY_CODES = {
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "kp0", "kp1", "kp2", "kp3", "kp4", "kp5", "kp6", "kp7", "kp8", "kp9",
  "space", "'", "-", "=", "[", "]", "\\", "/", ",", ".", ";", "kp+", "kp-", "kp*", "kp/", "kpenter",
  "up", "down", "left", "right", "home", "end", "pageup", "pagedown", "insert", "backspace", "tab", "return", "delete", "escape",
  "lshift", "rshift", "lctrl", "rctrl", "lalt", "ralt",
  "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12",
  "gp1_left", "gp1_right", "gp1_up", "gp1_down", "gp1_a", "gp1_b", "gp1_x", "gp1_y", "gp1_start", "gp1_back", "gp1_leftshoulder", "gp1_rightshoulder", "gp1_lt", "gp1_rt",
  "gp2_left", "gp2_right", "gp2_up", "gp2_down", "gp2_a", "gp2_b", "gp2_x", "gp2_y", "gp2_start", "gp2_back", "gp2_leftshoulder", "gp2_rightshoulder", "gp2_lt", "gp2_rt",
  "gp3_left", "gp3_right", "gp3_up", "gp3_down", "gp3_a", "gp3_b", "gp3_x", "gp3_y", "gp3_start", "gp3_back", "gp3_leftshoulder", "gp3_rightshoulder", "gp3_lt", "gp3_rt",
  "gp4_left", "gp4_right", "gp4_up", "gp4_down", "gp4_a", "gp4_b", "gp4_x", "gp4_y", "gp4_start", "gp4_back", "gp4_leftshoulder", "gp4_rightshoulder", "gp4_lt", "gp4_rt"
}
for _, v in pairs(KEY_CODES) do
  KB.cur_down[v] = false
  KB.held_timer[v] = 0
end

function KB.update()
  local joysticks = love.joystick.getJoysticks()
  for _, v in pairs(KEY_CODES) do
    KB.prev_down[v] = KB.cur_down[v]
    local cur_down
    if v:sub(1, 2) == "gp" then
      local gp_index = tonumber(v:sub(3, 3))
      if joysticks[gp_index] == nil or not joysticks[gp_index]:isGamepad() then
        cur_down = false
      else
        local joystick = joysticks[gp_index]
        local key = v:sub(5, -1)
        if key == "left" then
          cur_down = joystick:getGamepadAxis("leftx") < -0.5 or joystick:isGamepadDown("dpleft")
        elseif key == "right" then
          cur_down = joystick:getGamepadAxis("leftx") > 0.5 or joystick:isGamepadDown("dpright")
        elseif key == "up" then
          cur_down = joystick:getGamepadAxis("lefty") < -0.5 or joystick:isGamepadDown("dpup")
        elseif key == "down" then
          cur_down = joystick:getGamepadAxis("lefty") > 0.5 or joystick:isGamepadDown("dpdown")
        elseif key == "lt" then
          cur_down = joystick:getGamepadAxis("triggerleft") > 0.5
        elseif key == "rt" then
          cur_down = joystick:getGamepadAxis("triggerright") > 0.5
        else
          cur_down = joystick:isGamepadDown(key)
        end
      end
    else
      cur_down = love.keyboard.isDown(v)
    end

    if cur_down then
      KB.held_timer[v] = KB.held_timer[v] + 1
    else
      KB.held_timer[v] = 0
    end
    KB.cur_down[v] = cur_down
  end
end

function KB.down(key)
  return KB.cur_down[key]
end

function KB.pressed(key)
  return KB.cur_down[key] and not KB.prev_down[key]
end

function KB.released(key)
  return KB.prev_down[key] and not KB.cur_down[key]
end

function KB.held(key)
  return KB.held_timer[key] >= KB.held_delay and (KB.held_timer[key] - KB.held_delay) % KB.held_interval == 0
end
