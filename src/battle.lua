Battle = {}
Battle.__index = Battle

function Battle.new(scene_index, initiator)
  local self = setmetatable({}, Battle)
  return self
end

function Battle:update()
  print("--- battle")
end

function Battle:draw() end
