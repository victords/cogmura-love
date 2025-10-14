Song = setmetatable({}, Sound)
Song.__index = Song

function Song.new(path)
  local self = setmetatable({}, Song)
  self.source = love.audio.newSource(path, "stream")
  return self
end

function Song:play(volume, looping, stop_current)
  if Song.current and (stop_current or stop_current == nil) then
    Song.current:stop()
  end
  Song.current = self

  self.source:setVolume(volume or 1)
  self.source:setLooping(looping or looping == nil)
  self.source:play()
end

function Song:stop()
  if self == Song.current then Song.current = nil end
  self.source:stop()
end

function Song:playing()
  return self.source:isPlaying()
end

function Song:set_volume(volume)
  self.source:setVolume(volume)
end
