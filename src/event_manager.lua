EventManager = {
  handlers = {},
  listen = function(event_name, handler)
    if EventManager.handlers[event_name] == nil then
      EventManager.handlers[event_name] = {}
    end
    table.insert(EventManager.handlers[event_name], handler)
  end,
  trigger = function(event_name, ...)
    for _, handler in ipairs(EventManager.handlers[event_name]) do
      handler(...)
    end
  end
}
