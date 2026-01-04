EventManager = {
  handlers = {},
  listen = function(event_name, handler, obj)
    if EventManager.handlers[event_name] == nil then
      EventManager.handlers[event_name] = {}
    end
    table.insert(EventManager.handlers[event_name], {handler, obj})
  end,
  trigger = function(event_name, ...)
    if EventManager.handlers[event_name] == nil then return end

    for _, handler_and_obj in ipairs(EventManager.handlers[event_name]) do
      if handler_and_obj[2] then
        handler_and_obj[1](handler_and_obj[2], ...)
      else
        handler_and_obj[1](...)
      end
    end
  end
}
