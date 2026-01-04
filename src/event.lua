Event = {}
Event.__index = Event

function Event.new()
  local self = setmetatable({}, Event)
  self.handlers = {}
  return self
end

function Event:listen(handler, obj)
  table.insert(self.handlers, {handler, obj})
end

function Event:trigger(...)
  for _, handler_and_obj in ipairs(self.handlers) do
    if handler_and_obj[2] then
      handler_and_obj[1](handler_and_obj[2], ...)
    else
      handler_and_obj[1](...)
    end
  end
end
