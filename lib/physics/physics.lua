Physics = {
  gravity = Vector.new(0, 1),
  min_speed = Vector.new(0.01, 0.01),
  ramp_contact_threshold = 4,
  ramp_slip_threshold = 1,
  ramp_slip_force = 1,
  epsilon = 0.001,
  engine = "minigl",
  setEngine = function(engine)
    if engine ~= "minigl" and engine ~= "love" then
      error("Unsupported physics engine '" .. engine .. "'")
    end

    Physics.engine = engine
    if engine == "love" then
      Physics.world = love.physics.newWorld(Physics.gravity.x, Physics.gravity.y)
      Physics.world:setCallbacks(Physics.begin_contact, Physics.end_contact)
    end
  end,
  update = function(dt)
    if Physics.engine == "minigl" then return end

    Physics.world:update(dt)
  end,
  begin_contact = function(f1, f2, contact)
    local obj1 = f1:getBody():getUserData()
    local obj2 = f2:getBody():getUserData()
    local normal_x, normal_y = contact:getNormal()

    if getmetatable(obj1).set_contacts then
      obj1:set_contacts(obj2, normal_x, normal_y)
    end
    if getmetatable(obj2).set_contacts then
      obj2:set_contacts(obj1, -normal_x, -normal_y)
    end
  end,
  end_contact = function(f1, f2, contact)
    local obj1 = f1:getBody():getUserData()
    local obj2 = f2:getBody():getUserData()

    if getmetatable(obj1).clear_contacts then
      obj1:clear_contacts(obj2)
    end
    if getmetatable(obj2).clear_contacts then
      obj2:clear_contacts(obj1)
    end
  end
}
