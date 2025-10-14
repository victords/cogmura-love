TextHelper = {}
TextHelper.__index = TextHelper

function TextHelper.new(font, line_spacing, scale)
  local self = setmetatable({}, TextHelper)
  self.font = font
  self.line_spacing = line_spacing or 0
  self.scale = scale or 1
  return self
end

function TextHelper:write_line(text, x, y, alignment, color, effect, effect_size, effect_color, scale)
  alignment = alignment or "left"
  color = color or {1, 1, 1}
  effect_size = effect_size or 1
  effect_color = effect_color or {0, 0, 0}
  local rel_x = alignment == "center" and 0.5 or (alignment == "right" and 1 or 0)
  if effect == "border" then
    self.font:draw_text_rel(text, x - effect_size, y - effect_size, rel_x, 0, effect_color, scale)
    self.font:draw_text_rel(text, x, y - effect_size, rel_x, 0, effect_color, scale)
    self.font:draw_text_rel(text, x + effect_size, y - effect_size, rel_x, 0, effect_color, scale)
    self.font:draw_text_rel(text, x + effect_size, y, rel_x, 0, effect_color, scale)
    self.font:draw_text_rel(text, x + effect_size, y + effect_size, rel_x, 0, effect_color, scale)
    self.font:draw_text_rel(text, x, y + effect_size, rel_x, 0, effect_color, scale)
    self.font:draw_text_rel(text, x - effect_size, y + effect_size, rel_x, 0, effect_color, scale)
    self.font:draw_text_rel(text, x - effect_size, y, rel_x, 0, effect_color, scale)
  elseif effect == "shadow" then
    self.font:draw_text_rel(text, x + effect_size, y + effect_size, rel_x, 0, effect_color, scale)
  end
  self.font:draw_text_rel(text, x, y, rel_x, 0, color, scale)
end

function TextHelper:write_breaking(text, x, y, width, alignment, color, scale, line_spacing)
  alignment = alignment or "left"
  color = color or {1, 1, 1}
  scale = scale or self.scale
  line_spacing = line_spacing or self.line_spacing
  for p in text:gmatch("[^\n]+") do
    if alignment == "justify" then
      y = self:write_paragraph_justify(p, x, y, width, color, scale, line_spacing)
    else
      local rel_x = alignment == "center" and 0.5 or (alignment == "right" and 1 or 0)
      y = self:write_paragraph(p, x, y, width, rel_x, color, scale, line_spacing)
    end
  end
end

-- private
function TextHelper:write_paragraph(p, x, y, width, rel_x, color, scale, line_spacing)
  local line = ""
  local line_width = 0
  for word in p:gmatch("[^ ]+") do
    local w = self.font:text_width(word)
    if line_width + w * scale > width then
      self.font:draw_text_rel(line:sub(1, -2), x, y, rel_x, 0, color, scale)
      line = ""
      line_width = 0
      y = y + (self.font.height + line_spacing) * scale
    end
    line = line .. word .. " "
    line_width = line_width + Utils.round(self.font:text_width(word .. " ") * scale)
  end
  if line ~= "" then
    self.font:draw_text_rel(line:sub(1, -2), x, y, rel_x, 0, color, scale)
  end
  return y + (self.font.height + line_spacing) * scale
end

function TextHelper:write_paragraph_justify(p, x, y, width, color, scale, line_spacing)
  local space_width = self.font:text_width(' ') * scale
  local spaces = {{}}
  local line_index = 1
  local new_x = x
  local words = Utils.split(p, ' ')
  for _, word in ipairs(words) do
    local w = self.font:text_width(word)
    if new_x + w * scale > x + width then
      local space = x + width - new_x + space_width
      local index = 1
      for _ = space, 1, -1 do
        spaces[line_index][index] = spaces[line_index][index] + 1
        index = index + 1
        if index == #spaces[line_index] then index = 1 end
      end

      table.insert(spaces, {})
      line_index = line_index + 1
      new_x = x
    end
    new_x = new_x + self.font:text_width(word) * scale + space_width
    table.insert(spaces[line_index], space_width)
  end

  local index = 1
  for _, line in ipairs(spaces) do
    new_x = x
    for _, s in ipairs(line) do
      self.font:draw_text(words[index], new_x, y, color, scale)
      new_x = new_x + self.font:text_width(words[index]) * scale + s
      index = index + 1
    end
    y = y + (self.font.height + line_spacing) * scale
  end
  return y
end
