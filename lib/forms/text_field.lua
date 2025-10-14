TextField = setmetatable({}, Component)
TextField.__index = TextField

KEYS_TO_CHARS = {
  ["a"] = {"a", "A"}, ["b"] = {"b", "B"}, ["c"] = {"c", "C"}, ["d"] = {"d", "D"},
  ["e"] = {"e", "E"}, ["f"] = {"f", "F"}, ["g"] = {"g", "G"}, ["h"] = {"h", "H"},
  ["i"] = {"i", "I"}, ["j"] = {"j", "J"}, ["k"] = {"k", "K"}, ["l"] = {"l", "L"},
  ["m"] = {"m", "M"}, ["n"] = {"n", "N"}, ["o"] = {"o", "O"}, ["p"] = {"p", "P"},
  ["q"] = {"q", "Q"}, ["r"] = {"r", "R"}, ["s"] = {"s", "S"}, ["t"] = {"t", "T"},
  ["u"] = {"u", "U"}, ["v"] = {"v", "V"}, ["w"] = {"w", "W"}, ["x"] = {"x", "X"},
  ["y"] = {"y", "Y"}, ["z"] = {"z", "Z"},
  ["0"] = {"0", ")"}, ["1"] = {"1", "!"}, ["2"] = {"2", "@"}, ["3"] = {"3", "#"},
  ["4"] = {"4", "$"}, ["5"] = {"5", "%"}, ["6"] = {"6", "^"}, ["7"] = {"7", "&"},
  ["8"] = {"8", "*"}, ["9"] = {"9", "("},
  ["kp0"] = {"0", "0"}, ["kp1"] = {"1", "1"}, ["kp2"] = {"2", "2"}, ["kp3"] = {"3", "3"},
  ["kp4"] = {"4", "4"}, ["kp5"] = {"5", "5"}, ["kp6"] = {"6", "6"}, ["kp7"] = {"7", "7"},
  ["kp8"] = {"8", "8"}, ["kp9"] = {"9", "9"},
  ["kp+"] = {"+", "+"}, ["kp-"] = {"-", "-"}, ["kp*"] = {"*", "*"}, ["kp/"] = {"/", "/"},
  ["space"] = {" ", " "}, ["'"] = {"'", '"'}, ["-"] = {"-", "_"}, ["="] = {"=", "+"},
  ["["] = {"[", "{"}, ["]"] = {"]", "}"}, ["\\"] = {"\\", "|"}, ["/"] = {"/", "?"},
  [","] = {",", "<"}, ["."] = {".", ">"}, [";"] = {";", ":"}
}

function TextField.new(x, y, options, on_text_changed)
  local scale = options.scale or 1
  local img, w, h
  if options.img_path then
    img = Res.tileset(options.img_path, 1, 2)
    w = scale * img.tile_width
    h = scale * img.tile_height
  else
    w = options.w or 150
    h = options.h or 30
  end

  local self = Component.new(x, y, w, h, options)
  setmetatable(self, TextField)

  if options.cursor_img_path then
    self.cursor_img = Res.img(options.cursor_img_path)
    self.cursor_img_gap = options.cursor_img_gap or Vector.new()
  else
    self.cursor_color = options.cursor_color or {0, 0, 0}
  end

  self.img = img
  self.scale = scale
  self.max_length = options.max_length or 100
  self.focused = options.focused == nil or options.focused
  self.margin_x = options.margin_x or 0
  self.margin_y = options.margin_y or 0
  self.center_y = options.center_y == nil or options.center_y
  self.text_x = self.x + self.margin_x
  self.text_y = self.y + self.margin_y + (self.center_y and (self.h - self.font.height * scale) / 2 or 0)
  self.selection_color = options.selection_color or {0, 0, 0, 0.4}
  self.cursor_blink_interval = options.cursor_blink_interval or 30
  self.allowed_chars = options.allowed_chars
  self.params = options.params
  self.on_text_changed = on_text_changed

  self.cursor_visible = false
  self.cursor_timer = 0
  self:set_text(self.text or '', false)

  return self
end

function TextField:update()
  if not (self.enabled and self.visible) then return end

  -- Mouse --------------------------------------------------------------------
  if Mouse.over(self:get_bounds()) then
    if not self.focused and Mouse.pressed("left") and not Mouse.click_captured then
      self:focus()
      return
    end
  elseif Mouse.pressed("left") then
    self:unfocus()
  end

  if not self.focused then return end

  if not Mouse.click_captured then
    if Mouse.double_clicked("left") then
      if #self.nodes > 1 then
        self.anchor1 = 1
        self.anchor2 = #self.nodes
        self.cur_node = self.anchor2
        self.double_clicked = true
      end
      self:set_cursor_visible()
      Mouse.click_captured = true
    elseif Mouse.pressed("left") then
      self:focus_and_set_anchor()
      Mouse.click_captured = true
    elseif Mouse.down("left") then
      if self.anchor1 and not self.double_clicked then
        self:set_node_by_mouse()
        self.anchor2 = self.cur_node ~= self.anchor1 and self.cur_node or nil
        self:set_cursor_visible()
      end
      Mouse.click_captured = true
    elseif Mouse.released("left") and self.anchor1 and not self.double_clicked then
      if self.cur_node == self.anchor1 then
        self.anchor1 = nil
      else
        self.anchor2 = self.cur_node
      end
    end
  end

  self.cursor_timer = self.cursor_timer + 1
  if self.cursor_timer >= self.cursor_blink_interval then
    self.cursor_visible = not self.cursor_visible
    self.cursor_timer = 0
  end

  -- Keyboard -----------------------------------------------------------------
  local shift = KB.down("lshift") or KB.down("rshift")
  if KB.pressed("lshift") or KB.pressed("rshift") then
    if self.anchor1 == nil then self.anchor1 = self.cur_node end
  elseif KB.released("shift") or KB.released("rshift") then
    if self.anchor2 == nil then self.anchor1 = nil end
  end

  local inserted = false
  for key, chars in pairs(KEYS_TO_CHARS) do
    if KB.pressed(key) or KB.held(key) then
      if self.anchor1 and self.anchor2 then self:remove_interval(true) end
      self:insert_char(shift and chars[2] or chars[1])
      inserted = true
      break
    end
  end
  if inserted then return end

  if KB.pressed("backspace") or KB.held("backspace") then
    if self.anchor1 and self.anchor2 then
      self:remove_interval()
    elseif self.cur_node > 1 then
      self:remove_char(true)
    end
  elseif KB.pressed("delete") or KB.held("delete") then
    if self.anchor1 and self.anchor2 then
      self:remove_interval()
    elseif self.cur_node < #self.nodes then
      self:remove_char(false)
    end
  elseif KB.pressed("left") or KB.held("left") then
    if self.anchor1 then
      if shift then
        if self.cur_node > 1 then
          self.cur_node = self.cur_node - 1
          self.anchor2 = self.cur_node
          self:set_cursor_visible()
        end
      elseif self.anchor2 then
        self.cur_node = self.anchor1 < self.anchor2 and self.anchor1 or self.anchor2
        self.anchor1 = nil
        self.anchor2 = nil
        self:set_cursor_visible()
      end
    elseif self.cur_node > 1 then
      self.cur_node = self.cur_node - 1
      self:set_cursor_visible()
    end
  elseif KB.pressed("right") or KB.held("right") then
    if self.anchor1 then
      if shift then
        if self.cur_node < #self.nodes then
          self.cur_node = self.cur_node + 1
          self.anchor2 = self.cur_node
          self:set_cursor_visible()
        end
      elseif self.anchor2 then
        self.cur_node = self.anchor1 > self.anchor2 and self.anchor1 or self.anchor2
        self.anchor1 = nil
        self.anchor2 = nil
        self:set_cursor_visible()
      end
    elseif self.cur_node < #self.nodes then
      self.cur_node = self.cur_node + 1
      self:set_cursor_visible()
    end
  elseif KB.pressed("home") then
    self.cur_node = 1
    if shift then
      self.anchor2 = self.cur_node
    else
      self.anchor1 = nil; self.anchor2 = nil
    end
    self:set_cursor_visible()
  elseif KB.pressed("end") then
    self.cur_node = #self.nodes
    if shift then
      self.anchor2 = self.cur_node
    else
      self.anchor1 = nil; self.anchor2 = nil
    end
    self:set_cursor_visible()
  end
end

function TextField:set_text(text, trigger_changed)
  self.text = text.sub(1, self.max_length)
  self.nodes = {self.text_x}
  local x = self.nodes[1]
  for char in self.text:gmatch('.') do
    x = x + self.font:text_width(char) * self.scale
    table.insert(self.nodes, x)
  end

  self.cur_node = #self.nodes
  self.anchor1 = nil; self.anchor2 = nil
  if self.on_text_changed and (trigger_changed == nil or trigger_changed) then
    self.on_text_changed(self.text, self.params)
  end
end

function TextField:selected_text()
  if self.anchor2 == nil then return '' end

  local min = self.anchor1 < self.anchor2 and self.anchor1 or self.anchor2
  local max = min == self.anchor1 and self.anchor2 or self.anchor1
  return self.text:sub(min, max - 1)
end

function TextField:focus()
  self.focused = true
  self.anchor2 = nil
  self.double_clicked = false
  self:set_node_by_mouse()
  self:set_cursor_visible()
end

function TextField:unfocus()
  self.anchor1 = nil; self.anchor2 = nil
  self.cursor_visible = false
  self.focused = false
  self.cursor_timer = 0
end

function TextField:set_position(x, y)
  local d_x = x - self.x
  local d_y = y - self.y
  self.x = x
  self.y = y
  self.text_x = self.text_x + d_x
  self.text_y = self.text_y + d_y
  for i, v in ipairs(self.nodes) do
    self.nodes[i] = v + d_x
  end
end

function TextField:draw(color)
  if not self.visible then return end

  if self.img then
    self.img[self.enabled and 1 or 2]:draw(self.x, self.y, self.scale, self.scale, nil, color)
  else
    local rect_color = Utils.clone(color or {1, 1, 1})
    if not self.enabled then
      rect_color[1] = rect_color[1] * 0.6
      rect_color[2] = rect_color[2] * 0.6
      rect_color[3] = rect_color[3] * 0.6
    end
    Window.draw_rectangle(self.x, self.y, self.w, self.h, rect_color)
  end

  if text ~= '' then
    local text_color = self.enabled and self.text_color or self.disabled_text_color
    self.font:draw_text(self.text, self.text_x, self.text_y, text_color, self.scale)
  end

  if self.anchor1 and self.anchor2 then
    local min = self.anchor1 < self.anchor2 and self.anchor1 or self.anchor2
    local max = min == self.anchor1 and self.anchor2 or self.anchor1
    Window.draw_rectangle(self.nodes[min], self.text_y, self.nodes[max] - self.nodes[min], self.font.height * self.scale, self.selection_color)
  end

  if self.cursor_visible then
    local cursor_x = self.nodes[self.cur_node]
    if self.cursor_img then
      self.cursor_img:draw(cursor_x + self.cursor_img_gap.x, self.text_y + self.cursor_img_gap.y, self.scale, self.scale)
    else
      Window.draw_rectangle(cursor_x, self.text_y, 1, self.font.height * self.scale, self.cursor_color)
    end
  end
end

function TextField:set_enabled(value)
  self.enabled = value
  if not value then self:unfocus() end
end

function TextField:set_visible(value)
  self.visible = value
  if not value then self:unfocus() end
end

-- private
function TextField:focus_and_set_anchor()
  self:focus()
  self.anchor1 = self.cur_node
end

function TextField:set_cursor_visible()
  self.cursor_visible = true
  self.cursor_timer = 0
end

function TextField:set_node_by_mouse()
  local index = #self.nodes
  for i, n in ipairs(self.nodes) do
    if n >= Mouse.x then
      index = i
      break
    end
  end
  if index > 1 then
    local d1 = self.nodes[index] - Mouse.x
    local d2 = Mouse.x - self.nodes[index - 1]
    if d1 > d2 then index = index - 1 end
  end
  self.cur_node = index
end

function TextField:insert_char(char)
  if not (#self.text < self.max_length and (self.allowed_chars == nil or self.allowed_chars:find(char))) then
    return
  end

  local char_width = self.font:text_width(char) * self.scale
  self.text = self.text:sub(1, self.cur_node - 1) .. char .. self.text:sub(self.cur_node, -1)
  table.insert(self.nodes, self.cur_node + 1, self.nodes[self.cur_node] + char_width)
  for i = self.cur_node + 2, #self.nodes do
    self.nodes[i] = self.nodes[i] + char_width
  end
  self.cur_node = self.cur_node + 1
  self:set_cursor_visible()
  if self.on_text_changed then
    self.on_text_changed(self.text, self.params)
  end
end

function TextField:remove_interval(will_insert)
  local min = self.anchor1 < self.anchor2 and self.anchor1 or self.anchor2
  local max = min == self.anchor1 and self.anchor2 or self.anchor1
  local interval_width = 0
  for i = min, max - 1 do
    interval_width = interval_width + self.font:text_width(self.text:sub(i, i)) * self.scale
    table.remove(self.nodes, min + 1)
  end
  self.text = self.text:sub(1, min - 1) .. self.text:sub(max, -1)
  for i = min + 1, #self.nodes do
    self.nodes[i] = self.nodes[i] - interval_width
  end
  self.cur_node = min
  self.anchor1 = nil; self.anchor2 = nil
  self:set_cursor_visible()
  if self.on_text_changed and not will_insert then
    self.on_text_changed(self.text, self.params)
  end
end

function TextField:remove_char(back)
  if back then self.cur_node = self.cur_node - 1 end
  local char_width = self.font:text_width(self.text:sub(self.cur_node, self.cur_node)) * self.scale
  self.text = self.text:sub(1, self.cur_node - 1) .. self.text:sub(self.cur_node + 1, -1)
  table.remove(self.nodes, self.cur_node + 1)
  for i = self.cur_node + 1, #self.nodes do
    self.nodes[i] = self.nodes[i] - char_width
  end
  self:set_cursor_visible()
  if self.on_text_changed then
    self.on_text_changed(self.text, self.params)
  end
end
