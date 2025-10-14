Window = {}
Window.__index = Window

function Window.init(fullscreen, width, height, reference_width, reference_height)
  width = width or 1280
  height = height or 720
  reference_width = reference_width or 1280
  reference_height = reference_height or 720

  Window.width = width
  Window.height = height
  Window.reference_width = reference_width
  Window.reference_height = reference_height

  local screen_width, screen_height
  if fullscreen then
    local _, _, flags = love.window.getMode()
    local w, h = love.window.getDesktopDimensions(flags.display)
    screen_width = w
    screen_height = h
  else
    screen_width = width
    screen_height = height
  end

  if screen_width ~= reference_width or screen_height ~= reference_height then
    local screen_ratio = screen_width / screen_height
    local reference_ratio = reference_width / reference_height
    if screen_ratio > reference_ratio then
      Window.scale = screen_height / reference_height
    else
      Window.scale = screen_width / reference_width
    end
    Window.offset_x = math.floor((screen_width - Window.scale * reference_width) / 2)
    Window.offset_y = math.floor((screen_height - Window.scale * reference_height) / 2)
    Window.canvas = love.graphics.newCanvas(reference_width, reference_height)
  else
    Window.scale = 1
    Window.offset_x = 0
    Window.offset_y = 0
    if Window.shader then
      Window.canvas = love.graphics.newCanvas(reference_width, reference_height)
    else
      Window.canvas = nil
    end
  end

  love.window.setMode(screen_width, screen_height, { fullscreen = fullscreen })
end

function Window.toggle_fullscreen()
  local currently_fullscreen = love.window.getFullscreen()
  Window.set_size(not currently_fullscreen, Window.width, Window.height, Window.reference_width, Window.reference_height)
end

function Window.set_shader(path)
  Window.shader = Res.shader(path)
  if Window.canvas == nil then
    Window.canvas = love.graphics.newCanvas(Window.reference_width, Window.reference_height)
  end
end

function Window.draw_rectangle(x, y, w, h, color, mode)
  color = color or {1, 1, 1}
  mode = mode or "fill"
  love.graphics.setColor(color)
  love.graphics.rectangle(mode, x, y, w, h)
  love.graphics.setColor(1, 1, 1)
end

function Window.draw(draw_code)
  if Window.canvas then
    love.graphics.setCanvas(Window.canvas)
    love.graphics.clear()
  end

  draw_code()

  if Window.canvas then
    if Window.shader then love.graphics.setShader(Window.shader) end
    love.graphics.setCanvas()
    love.graphics.draw(Window.canvas, Window.offset_x, Window.offset_y, nil, Window.scale, Window.scale)
    if Window.shader then love.graphics.setShader() end
  end
end
