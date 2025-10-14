Sound = {}
Sound.__index = Sound

function Sound.new(path)
  local self = setmetatable({}, Sound)
  self.source = love.audio.newSource(path, "static")
  return self
end

function Sound:play(volume, looping)
  if self:playing() then self:stop() end
  self.source:setVolume(volume or 1)
  self.source:setLooping(looping or false)
  self.source:play()
end

function Sound:pause()
  self.source:pause()
end

function Sound:stop()
  self.source:stop()
end

function Sound:playing()
  return self.source:isPlaying()
end
