Res = {
  prefix = "data/",
  font_prefix = "font/",
  img_prefix = "img/",
  song_prefix = "song/",
  sound_prefix = "sound/",
  tileset_prefix = "img/",
  shader_prefix = "shaders/",
  fonts = {},
  imgs = {},
  songs = {},
  sounds = {},
  tilesets = {},
  shaders = {},
  font = function(path, size, extension)
    local key = path .. "_" .. size
    if Res.fonts[key] then return Res.fonts[key] end

    extension = extension or "ttf"
    local full_path = Res.prefix .. Res.font_prefix .. path .. "." .. extension
    local font = Font.new(full_path, size)
    Res.fonts[key] = font
    return font
  end,
  img = function(path, extension)
    if Res.imgs[path] then return Res.imgs[path] end

    extension = extension or "png"
    local full_path = Res.prefix .. Res.img_prefix .. path .. "." .. extension
    local img = Image.new(full_path)
    Res.imgs[path] = img
    return img
  end,
  img_font = function(path, characters, char_spacing, extension)
    local key = path .. "_" .. "img" .. "_" .. char_spacing
    if Res.fonts[key] then return Res.fonts[key] end

    extension = extension or "png"
    local full_path = Res.prefix .. Res.font_prefix .. path .. "." .. extension
    local font = ImageFont.new(full_path, characters, char_spacing)
    Res.fonts[key] = font
    return font
  end,
  song = function(path, extension)
    if Res.songs[path] then return Res.songs[path] end

    extension = extension or "ogg"
    local full_path = Res.prefix .. Res.song_prefix .. path .. "." .. extension
    local song = Song.new(full_path)
    Res.songs[path] = song
    return song
  end,
  sound = function(path, extension)
    if Res.sounds[path] then return Res.sounds[path] end

    extension = extension or "wav"
    local full_path = Res.prefix .. Res.sound_prefix .. path .. "." .. extension
    local sound = Sound.new(full_path)
    Res.sounds[path] = sound
    return sound
  end,
  tileset = function(path, cols, rows, extension)
    if Res.tilesets[path] then return Res.tilesets[path] end

    extension = extension or "png"
    local full_path = Res.prefix .. Res.tileset_prefix .. path .. "." .. extension
    local tileset = Tileset.new(full_path, cols, rows)
    Res.tilesets[path] = tileset
    return tileset
  end,
  shader = function(path, extension)
    if Res.shaders[path] then return Res.shaders[path] end

    extension = extension or "glsl"
    local full_path = Res.shader_prefix .. path .. "." .. extension
    local shader = love.graphics.newShader(full_path)
    Res.shaders[path] = shader
    return shader
  end
}

Utils = {
  include = function(class, module)
    for k, v in pairs(module) do
      class[k] = v
    end
  end,
  approx_equal = function (value1, value2, tolerance)
    tolerance = tolerance or 0.000001
    return math.abs(value1 - value2) <= tolerance
  end,
  round = function(value)
    return value >= 0 and math.floor(value + 0.5) or math.ceil(value - 0.5)
  end,
  clone = function(table)
    local clone = setmetatable({}, getmetatable(table))
    for k, v in pairs(table) do
      clone[k] = v
    end
    return clone
  end,
  split = function(str, separator)
    local t = {}
    for s in str:gmatch("[^" .. separator .. "]+") do
      table.insert(t, s)
    end
    return t
  end,
  join = function(table, separator)
    separator = separator or ""
    local result = ""
    for i, value in ipairs(table) do
      if i > 1 then result = result .. separator end
      result = result .. value
    end
    return result
  end,
  map = function(table, mapper)
    local mapped = {}
    for k, v in pairs(table) do
      mapped[k] = mapper(v)
    end
    return mapped
  end,
  check_anchor = function(anchor, x, y, w, h, area_w, area_h)
    area_w = area_w or Window.reference_width
    area_h = area_h or Window.reference_height
    local anchor_alias = nil
    if anchor then
      if anchor == "top" or anchor == "top_center" or anchor == "north" then anchor_alias = "top_center"; x = x + (area_w - w) / 2
      elseif anchor == "top_right" or anchor == "northeast" then anchor_alias = "top_right"; x = area_w - w - x
      elseif anchor == "left" or anchor == "center_left" or anchor == "west" then anchor_alias = "center_left"; y = y + (area_h - h) / 2
      elseif anchor == "center" then anchor_alias = "center"; x = x + (area_w - w) / 2; y = y + (area_h - h) / 2
      elseif anchor == "right" or anchor == "center_right" or anchor == "east" then anchor_alias = "center_right"; x = area_w - w - x; y = y + (area_h - h) / 2
      elseif anchor == "bottom_left" or anchor == "southwest" then anchor_alias = "bottom_left"; y = area_h - h - y
      elseif anchor == "bottom" or anchor == "bottom_center" or anchor == "south" then anchor_alias = "bottom_center"; x = x + (area_w - w) / 2; y = area_h - h - y
      elseif anchor == "bottom_right" or anchor == "southeast" then anchor_alias = "bottom_right"; x = area_w - w - x; y = area_h - h - y
      else anchor_alias = "top_left" end
    else
      anchor_alias = "top_left"
    end
    return anchor_alias, x, y
  end
}

require("lib.audio.song")
require("lib.audio.sound")

require("lib.forms.component")
require("lib.forms.button")
require("lib.forms.drop_down_list")
require("lib.forms.label")
require("lib.forms.panel")
require("lib.forms.text_field")
require("lib.forms.toggle_button")

require("lib.geometry.map")
require("lib.geometry.rectangle")
require("lib.geometry.vector")
require("lib.geometry.window")

require("lib.graphics.image")
require("lib.graphics.sprite")
require("lib.graphics.tileset")

require("lib.input.keyboard")
require("lib.input.mouse")

require("lib.physics.block")
require("lib.physics.game_object")
require("lib.physics.physics")
require("lib.physics.ramp")

require("lib.text.font")
require("lib.text.image_font")
require("lib.text.localization")
require("lib.text.text_helper")
