GameObject = setmetatable({}, Sprite)
GameObject.__index = GameObject
GameObject.__tostring = function(obj)
  return "GameObject (" .. obj.x .. ", " .. obj.y .. ", " .. obj.w .. ", " .. obj.h .. ")"
end

function GameObject.new(x, y, w, h, img_path, img_gap, cols, rows, physics_options)
  local self = Sprite.new(x, y, img_path, cols, rows)
  setmetatable(self, GameObject)
  self.w = w
  self.h = h
  self.img_gap = img_gap or Vector.new()

  if Physics.engine == "minigl" then
    self.mass = physics_options and physics_options.mass or 1
    self.max_speed = physics_options and physics_options.max_speed or Vector.new(15, 15)
    self.speed = Vector.new()
    self.stored_forces = Vector.new()
  elseif Physics.engine == "love" then
    self.body_type = physics_options and physics_options.body_type or "dynamic"
    self.body = love.physics.newBody(Physics.world, x + w / 2, y + h / 2, self.body_type)
    self.shape_type = physics_options and physics_options.shape or "rectangle"
    self.shape = self.shape_type == "circle" and
      love.physics.newCircleShape(w / 2) or
      love.physics.newRectangleShape(w, h)
    love.physics.newFixture(self.body, self.shape)
    if physics_options and physics_options.fixed_rotation then
      self.body:setFixedRotation(true)
    end
    self.body:setUserData(self)
  end

  return self
end

function GameObject:draw(scale_x, scale_y, color, angle, flip, z_index, scale_img_gap, round)
  if self.img == nil then return end

  scale_x = scale_x or 1
  scale_y = scale_y or 1
  if scale_img_gap == nil then scale_img_gap = true end
  local img_gap_scale_x = scale_img_gap and scale_x or 1
  local img_gap_scale_y = scale_img_gap and scale_y or 1
  local origin_x = 0.5 * (self.w / scale_x) - self.img_gap.x
  local origin_y = 0.5 * (self.h / scale_y) - self.img_gap.y
  local x = Physics.engine == "minigl" and self.x or self.body:getX() - self.w / 2
  local y = Physics.engine == "minigl" and self.y or self.body:getY() - self.h / 2
  x = x + img_gap_scale_x * self.img_gap.x + scale_x * origin_x
  y = y + img_gap_scale_y * self.img_gap.y + scale_y * origin_y
  if round then
    x = Utils.round(x)
    y = Utils.round(y)
  end
  local scale_x_factor = flip == "horiz" and -1 or 1
  local scale_y_factor = flip == "vert" and -1 or 1

  Window.draw_image(self.img.source, x, y, z_index, color, scale_x_factor * scale_x, scale_y_factor * scale_y, angle, origin_x, origin_y, self.quads[self.img_index])
end

function GameObject:draw_shape(color, z_index)
  if Physics.engine == "love" then
    if self.shape_type == "circle" then
      Window.draw_circle(self.body:getX(), self.body:getY(), z_index, self.w / 2, color)
    else
      Window.draw_polygon(z_index, color, "fill", self.body:getWorldPoints(self.shape:getPoints()))
    end
  else
    Window.draw_rectangle(self.x, self.y, z_index, self.w, self.h, color)
  end
end

function GameObject:bounds()
  return Rectangle.new(self.x, self.y, self.w, self.h)
end

function GameObject:get_speed()
  if Physics.engine == "love" then
    local v_x, v_y = self.body:getLinearVelocity()
    return Vector.new(v_x, v_y)
  else
    return self.speed
  end
end

function GameObject:get_x()
  if Physics.engine == "love" then
    return self.body:getX()
  else
    return self.x
  end
end

function GameObject:get_y()
  if Physics.engine == "love" then
    return self.body:getY()
  else
    return self.y
  end
end

function GameObject:move(forces, obst, ramps, set_speed)
  if Physics.engine == "love" then
    for _, obj in ipairs(obst) do
      if obj.passable then
        obj.body:setActive(self.body:getY() + self.h / 2 <= obj.y)
      end
    end

    if set_speed then
      self.body:setLinearVelocity(forces.x, forces.y)
    else
      self.body:applyForce(forces.x, forces.y)
    end

    return
  end

  local speed = self.speed
  if set_speed then
    speed.x = forces.x
    speed.y = forces.y
  else
    forces = forces + Physics.gravity + self.stored_forces
    self.stored_forces = Vector.new()

    if (forces.x < 0 and self.left) or (forces.x > 0 and self.right) then forces.x = 0 end
    if (forces.y < 0 and self.top) or (forces.y > 0 and self.bottom) then forces.y = 0 end

    if getmetatable(self.bottom) == Ramp then
      local threshold = Physics.ramp_slip_threshold
      if self.bottom.ratio > threshold then
        forces.x = forces.x + (self.bottom.left and -1 or 1) * (self.bottom.ratio - threshold) * Physics.ramp_slip_force / threshold
      elseif forces.x > 0 and self.bottom.left or forces.x < 0 and not self.bottom.left then
        forces.x = forces.x * self.bottom.factor
      end
    end

    self.speed = speed + (forces / self.mass)
    speed = self.speed
  end

  if math.abs(speed.x) < Physics.min_speed.x then speed.x = 0 end
  if math.abs(speed.y) < Physics.min_speed.y then speed.y = 0 end
  if math.abs(speed.x) > self.max_speed.x then speed.x = (speed.x < 0 and -1 or 1) * self.max_speed.x end
  if math.abs(speed.y) > self.max_speed.y then speed.y = (speed.y < 0 and -1 or 1) * self.max_speed.y end
  self.prev_speed = Utils.clone(speed)

  if speed.x == 0 and speed.y == 0 then return end

  local x = speed.x < 0 and self.x + speed.x or self.x
  local y = speed.y < 0 and self.y + speed.y or self.y
  local w = self.w + math.abs(speed.x)
  local h = self.h + math.abs(speed.y)
  local move_bounds = Rectangle.new(x, y, w, h)
  local coll_list = {}
  for _, o in ipairs(obst) do
    if o ~= self and move_bounds:intersect(o:bounds()) then table.insert(coll_list, o) end
  end
  for _, r in ipairs(ramps) do
    r:check_can_collide(move_bounds)
  end

  if #coll_list > 0 then
    local up = speed.y < 0
    local rt = speed.x > 0
    local dn = speed.y > 0
    local lf = speed.x < 0
    if speed.x == 0 or speed.y == 0 then
      -- orthogonal movement
      if rt then
        local x_lim = self:find_right_limit(coll_list)
        if self.x + self.w + speed.x > x_lim then
          self.x = x_lim - self.w
          speed.x = 0
        end
      elseif lf then
        local x_lim = self:find_left_limit(coll_list)
        if self.x + speed.x < x_lim then
          self.x = x_lim
          speed.x = 0
        end
      elseif dn then
        local y_lim = self:find_down_limit(coll_list)
        if self.y + self.h + speed.y > y_lim then
          self.y = y_lim - self.h
          speed.y = 0
        end
      else -- up
        local y_lim = self:find_up_limit(coll_list)
        if self.y + speed.y < y_lim then
          self.y = y_lim
          speed.y = 0
        end
      end
    else
      -- diagonal movement
      x_aim = self.x + speed.x + (rt and self.w or 0)
      x_lim_def = {x_aim, nil}
      y_aim = self.y + speed.y + (dn and self.h or 0)
      y_lim_def = {y_aim, nil}
      for _, c in ipairs(coll_list) do
        self:find_limits(c, x_aim, y_aim, x_lim_def, y_lim_def, up, rt, dn, lf)
      end

      if x_lim_def[1] ~= x_aim and y_lim_def[1] ~= y_aim then
        x_time = (x_lim_def[1] - self.x - (lf and 0 or self.w)) / speed.x
        y_time = (y_lim_def[1] - self.y - (up and 0 or self.h)) / speed.y
        if x_time < y_time then
          self:stop_at_x(x_lim_def[1], lf)
          move_bounds = Rectangle.new(self.x, up and self.y + speed.y or self.y, self.w, self.h + math.abs(speed.y))
          if move_bounds:intersect(y_lim_def[2]:bounds()) then self:stop_at_y(y_lim_def[1], up) end
        else
          self:stop_at_y(y_lim_def[1], up)
          move_bounds = Rectangle.new(lf and self.x + speed.x or self.x, self.y, self.w + math.abs(speed.x), self.h)
          if move_bounds:intersect(x_lim_def[2]:bounds()) then self:stop_at_x(x_lim_def[1], lf) end
        end
      elseif x_lim_def[1] ~= x_aim then
        self:stop_at_x(x_lim_def[1], lf)
      elseif y_lim_def[1] ~= y_aim then
        self:stop_at_y(y_lim_def[1], up)
      end
    end
  end
  self.x = self.x + speed.x
  self.y = self.y + speed.y

  for _, r in ipairs(ramps) do
    r:check_intersection(self)
  end
  self:check_contact(obst, ramps)
end

function GameObject:move_carrying(arg, scalar_speed, carried_objs, obstacles, ramps, ignore_collision)
  if Physics.engine == "love" then return end

  local speed = self.speed
  local x_aim = nil
  local y_aim = nil
  if scalar_speed then
    local x_d = arg.x - self.x
    local y_d = arg.y - self.y
    distance = math.sqrt(x_d^2 + y_d^2)

    if distance == 0 then
      speed.x = 0
      speed.y = 0
      return
    end

    speed.x = x_d * scalar_speed / distance
    speed.y = y_d * scalar_speed / distance
    x_aim = self.x + speed.x
    y_aim = self.y + speed.y
  else
    x_aim = self.x + speed.x + Physics.gravity.x + arg.x
    y_aim = self.y + speed.y + Physics.gravity.y + arg.y
  end

  local passengers = {}
  for _, o in ipairs(carried_objs) do
    if self.x + self.w > o.x and o.x + o.w > self.x then
      local foot = o.y + o.h
      if Utils.approx_equal(foot, self.y) or (speed.y < 0 and foot < self.y and foot > y_aim) then
        table.insert(passengers, o)
      end
    end
  end

  local prev_x = self.x
  local prev_y = self.y
  if scalar_speed then
    if speed.x > 0 and x_aim >= arg.x or speed.x < 0 and x_aim <= arg.x then
      self.x = arg.x
      speed.x = 0
    else
      self.x = x_aim
    end
    if speed.y > 0 and y_aim >= arg.y or speed.y < 0 and y_aim <= arg.y then
      self.y = arg.y
      speed.y = 0
    else
      self.y = y_aim
    end
  else
    self:move(arg, ignore_collision and {} or obstacles, ignore_collision and {} or ramps)
  end

  local forces = Vector.new(self.x - prev_x, self.y - prev_y)
  local prev_g = Utils.clone(Physics.gravity)
  Physics.gravity.x = 0
  Physics.gravity.y = 0
  for _, p in ipairs(passengers) do
    if getmetatable(p).move then
      local prev_speed = Utils.clone(p.speed)
      local prev_forces = Utils.clone(p.stored_forces)
      local prev_bottom = p.bottom
      p.speed.x = 0
      p.speed.y = 0
      p.stored_forces.x = 0
      p.stored_forces.y = 0
      p.bottom = nil
      p:move(forces * p.mass, obstacles, ramps)
      p.speed = prev_speed
      p.stored_forces = prev_forces
      p.bottom = prev_bottom
    else
      p.x = p.x + forces.x
      p.y = p.y + forces.y
    end
  end
  Physics.gravity = prev_g
end

function GameObject:move_free(aim, scalar_speed)
  local speed = self.speed
  if type(aim) == "number" then -- aim is an angle in degrees
    local rads = aim * math.pi / 180
    speed.x = scalar_speed * math.cos(rads)
    speed.y = scalar_speed * math.sin(rads)
    if Physics.engine == "love" then
      self.body:setLinearVelocity(speed.x, speed.y)
    else
      self.x = self.x + speed.x
      self.y = self.y + speed.y
    end
  else -- aim is a Vector
    local x_d = aim.x - self:get_x()
    local y_d = aim.y - self:get_y()
    if math.abs(x_d) < Physics.epsilon and math.abs(y_d) < Physics.epsilon then
      if Physics.engine == "love" then
        self.body:setLinearVelocity(0, 0)
        self.body:setX(aim.x)
        self.body:setY(aim.y)
      else
        speed.x = 0
        speed.y = 0
        self.x = aim.x
        self.y = aim.y
      end
      return
    end

    local angle = math.atan(y_d / x_d)
    local speed_x = scalar_speed * math.cos(angle) * (x_d < 0 and -1 or 1)
    local speed_y = scalar_speed * math.sin(angle) * (x_d < 0 and -1 or 1)

    if Physics.engine == "love" then
      local frame_speed_x = speed_x / 60
      local frame_speed_y = speed_y / 60
      if math.abs(x_d) < math.abs(frame_speed_x) then
        speed_x = x_d * 60
        speed_y = y_d * 60
      end
      self.body:setLinearVelocity(speed_x, speed_y)
    else
      speed.x = math.abs(x_d) < math.abs(speed_x) and x_d or speed_x
      speed.y = math.abs(y_d) < math.abs(speed_y) and y_d or speed_y
      self.x = self.x + speed.x
      self.y = self.y + speed.y
    end
  end
end

function GameObject:cycle(points, scalar_speed, stop_time, carried_objs, obstacles, ramps)
  stop_time = stop_time or 0
  if not self.cycle_setup then
    self.cur_point = self.cur_point or 1
    if carried_objs and Physics.engine == "minigl" then
      obstacles = obstacles or {}
      ramps = ramps or {}
      self:move_carrying(points[self.cur_point], scalar_speed, carried_objs, obstacles, ramps)
    else
      self:move_free(points[self.cur_point], scalar_speed)
    end
  end

  local speed = self:get_speed()
  if speed.x == 0 and speed.y == 0 then
    if not self.cycle_setup then
      self.cycle_timer = 0
      self.cycle_setup = true
    end
    if self.cycle_timer >= stop_time then
      if self.cur_point == #points then
        self.cur_point = 1
      else
        self.cur_point = self.cur_point + 1
      end
      self.cycle_setup = false
    else
      self.cycle_timer = self.cycle_timer + 1
    end
  end
end

function GameObject:set_contacts(obj, normal_x, normal_y)
  if normal_x < 0 then
    self.left = obj
  elseif normal_x > 0 then
    self.right = obj
  end
  if normal_y < 0 then
    self.top = obj
  elseif normal_y > 0 then
    self.bottom = obj
  end
end

function GameObject:clear_contacts(obj)
  if self.left == obj then self.left = nil end
  if self.right == obj then self.right = nil end
  if self.top == obj then self.top = nil end
  if self.bottom == obj then self.bottom = nil end
end

-- private
function GameObject:check_contact(obst, ramps)
  local prev_bottom = self.bottom
  self.left = nil; self.right = nil; self.top = nil; self.bottom = nil
  for _, o in ipairs(obst) do
    local x2 = self.x + self.w
    local y2 = self.y + self.h
    local x2o = o.x + o.w
    local y2o = o.y + o.h
    if not o.passable and Utils.approx_equal(x2, o.x) and y2 > o.y and self.y < y2o then self.right = o end
    if not o.passable and Utils.approx_equal(self.x, x2o) and y2 > o.y and self.y < y2o then self.left = o end
    if Utils.approx_equal(y2, o.y) and x2 > o.x and self.x < x2o then self.bottom = o end
    if not o.passable and Utils.approx_equal(self.y, y2o) and x2 > o.x and self.x < x2o then self.top = o end
  end
  if self.bottom == nil then
    for _, r in ipairs(ramps) do
      if r:contact(self) then
        self.bottom = r
        break
      end
    end
    if self.bottom == nil then
      for _, r in ipairs(ramps) do
        if r == prev_bottom and
           self.x + self.w > r.x and
           r.x + r.w > self.x and
           math.abs(self.prev_speed.x) <= Physics.ramp_contact_threshold and
           self.prev_speed.y >= 0 then
          self.y = r:get_y(self)
          self.bottom = r
          break
        end
      end
    end
  end
end

function GameObject:find_right_limit(coll_list)
  local limit = self.x + self.w + self.speed.x
  for _, c in ipairs(coll_list) do
    if not c.passable and c.x < limit then limit = c.x end
  end
  return limit
end

function GameObject:find_left_limit(coll_list)
  local limit = self.x + self.speed.x
  for _, c in ipairs(coll_list) do
    if not c.passable and c.x + c.w > limit then limit = c.x + c.w end
  end
  return limit
end

function GameObject:find_down_limit(coll_list)
  local limit = self.y + self.h + self.speed.y
  for _, c in ipairs(coll_list) do
    if c.y < limit and (not c.passable or c.y >= self.y + self.h) then limit = c.y end
  end
  return limit
end

function GameObject:find_up_limit(coll_list)
  local limit = self.y + self.speed.y
  for _, c in ipairs(coll_list) do
    if not c.passable and c.y + c.h > limit then limit = c.y + c.h end
  end
  return limit
end

function GameObject:find_limits(obj, x_aim, y_aim, x_lim_def, y_lim_def, up, rt, dn, lf)
  local x_lim = obj.x + obj.w
  if obj.passable then
    x_lim = x_aim
  elseif rt then
    x_lim = obj.x
  end

  local y_lim = obj.y + obj.h
  if dn then
    y_lim = obj.y
  elseif obj.passable then
    y_lim = y_aim
  end

  local x_v = x_lim_def[1]
  local y_v = y_lim_def[1]
  if obj.passable then
    if dn and self.y + self.h <= y_lim and y_lim < y_v then
      y_lim_def[1] = y_lim
      y_lim_def[2] = obj
    end
  elseif (rt and self.x + self.w > x_lim) or (lf and self.x < x_lim) then
    -- Can't limit by x, will limit by y
    if (dn and y_lim < y_v) or (up and y_lim > y_v) then
      y_lim_def[1] = y_lim
      y_lim_def[2] = obj
    end
  elseif (dn and self.y + self.h > y_lim) or (up and self.y < y_lim) then
    -- Can't limit by y, will limit by x
    if (rt and x_lim < x_v) or (lf and x_lim > x_v) then
      x_lim_def[1] = x_lim
      x_lim_def[2] = obj
    end
  else
    local x_time = (x_lim - self.x - (lf and 0 or self.w)) / self.speed.x
    local y_time = (y_lim - self.y - (up and 0 or self.h)) / self.speed.y
    if x_time > y_time then
      -- Will limit by x
      if (rt and x_lim < x_v) or (lf and x_lim > x_v) then
        x_lim_def[1] = x_lim
        x_lim_def[2] = obj
      end
    elseif (dn and y_lim < y_v) or (up and y_lim > y_v) then
      y_lim_def[1] = y_lim
      y_lim_def[2] = obj
    end
  end
end

function GameObject:stop_at_x(x, moving_left)
  self.speed.x = 0
  self.x = moving_left and x or x - self.w
end

function GameObject:stop_at_y(y, moving_up)
  self.speed.y = 0
  self.y = moving_up and y or y - self.h
end
