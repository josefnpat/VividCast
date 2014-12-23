local level = {}

function level.normalize(i)
  while i < 0 do
    i = i + math.pi*2
  end
  while i > math.pi*2 do
    i = i - math.pi*2
  end
  return i
end

function level.distance(a,b)
  return math.sqrt(
    (a:getX()-b:getX())^2 +
    (a:getY()-b:getY())^2 )
end

function level.angle(a,b)
  return math.atan2(
    a:getY()-b:getY(),
    a:getX()-b:getX())
end

function level:draw(x,y,rw,rh,sx,sy)
  sx = sx or 1
  sy = sy or sx or 1
  local w,h = rw/sx,rh/sy
  local old_color = {love.graphics.getColor()}

  if self._last_w ~= w or self._last_h ~= h then
    self._last_w = w
    self._last_h = h
    self._canvas = love.graphics.newCanvas(w,h)
  else
    self._canvas:clear()
  end
  local old_canvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self._canvas)

  for _,entity in pairs(self:getEntities()) do
    if entity ~= self:getPlayer() then
      entity._vision_angle = level.normalize(
        level.angle( self:getPlayer(), entity ) - math.pi )
      entity._vision_distance = level.distance( entity,self:getPlayer() )
      entity._vision_angle_width = math.atan2( 0.5, entity._vision_distance )
    end
  end

  local previous_ray_angle = level.normalize(
    self:getFOV()*(-1/w-0.5)+self:getPlayer():getAngle() )

  for i = 0,w do
    local ray_angle = level.normalize(
      self:getFOV()*(i/w-0.5)+self:getPlayer():getAngle() )
    local ray_x = self:getPlayer():getX()
    local ray_y = self:getPlayer():getY()
    local ray_length = 0

    local current_x,current_y

    repeat
      ray_x = ray_x + math.cos(ray_angle) * self:getRaycastResolution()
      ray_y = ray_y + math.sin(ray_angle) * self:getRaycastResolution()
      ray_length = ray_length + self:getRaycastResolution()

      new_x = math.floor(ray_x)
      new_y = math.floor(ray_y)
      if current_x ~= new_x or current_y ~= new_y then
        current_x,current_y = new_x,new_y
      end
    until self:getMapCallback()(current_x,current_y) ~= 0 or
      ray_length >= self:getRaycastRange()

    local tile_type = self:getMapCallback()(math.floor(ray_x),math.floor(ray_y))

    if ray_length < self:getRaycastRange() then

      local tile
      for i,v in pairs(self:getTiles()) do
        if v.type == tile_type then
          tile = v.tile
        end
      end
      assert(tile,"Tile type `"..tile_type.."` not set.")

      local draw_height = h/ray_length
      local darkness = (1-ray_length/self:getRaycastRange())*255

      local ray_xdist = math.abs(1-ray_x%1)
      local ray_ydist = math.abs(1-ray_y%1)

      local invert
      if ray_xdist > 1-self:getRaycastResolution() then
        distance = ray_y%1 -- east
        invert = false
      elseif ray_ydist > 1-self:getRaycastResolution() then
        distance = ray_x%1 -- south
        invert = true
      elseif ray_xdist < self:getRaycastResolution() then
        distance = ray_y%1 -- west
        invert = true
      elseif ray_ydist < self:getRaycastResolution() then
        distance = ray_x%1 -- north
        invert = false
      else
        distance = 0
      end

      love.graphics.setColor(darkness,darkness,darkness)

      local texture_scale = draw_height/tile:getTexture():getHeight()
      local texture_quad
      if invert then
        texture_quad = #tile:getQuad()-math.floor(distance*#tile:getQuad())
      else
        texture_quad = math.floor(distance*#tile:getQuad())+1
      end
      love.graphics.draw(
        tile:getTexture(),
        tile:getQuad()[texture_quad],
        i, (h-draw_height)/2,0,
        1,texture_scale)
    end

    for _,entity in pairs(self:getEntities()) do
      if entity ~= self:getPlayer() then
        if entity._vision_distance < ray_length and
          entity._vision_distance < self:getRaycastRange() and
          entity._vision_angle-entity._vision_angle_width<=ray_angle and
          entity._vision_angle+entity._vision_angle_width>previous_ray_angle then
          local distance = ( ( (ray_angle+previous_ray_angle)/2 - entity._vision_angle ) /
            entity._vision_angle_width +1) /2
          if distance > 1 then distance = distance-1 end
          if distance < 0 then distance = distance+1 end

          local darkness = (1-entity._vision_distance/self:getRaycastRange())*255
          love.graphics.setColor(darkness,darkness,darkness)
          local draw_height = h/entity._vision_distance
          local texture_scale = draw_height/entity:getTexture():getHeight()
          local texture_quad = math.floor(distance*#entity:getQuad())+1
          love.graphics.draw(
            entity:getTexture(),
            entity:getQuad()[texture_quad],
            i, (h-draw_height)/2,0,
            1,texture_scale)
        end
      end
    end

    previous_ray_angle = ray_angle
  end

  love.graphics.setCanvas(old_canvas)
  love.graphics.setColor(255,255,255)
  love.graphics.draw(self._canvas,x,y,0,sx,sy)
  love.graphics.setColor(old_color)

end

-- LuaClassGen pregenerated functions

function level.new(init)
  init = init or {}
  local self={}
  self.draw=level.draw
  self._tiles={}
  self.addTile=level.addTile
  self.removeTile=level.removeTile
  self.getTiles=level.getTiles
  self._entitys={}
  self.addEntity=level.addEntity
  self.removeEntity=level.removeEntity
  self.getEntities=level.getEntities
  self._player=init.player
  self.getPlayer=level.getPlayer
  self.setPlayer=level.setPlayer
  self._raycastRange=init.raycastRange
  self.getRaycastRange=level.getRaycastRange
  self.setRaycastRange=level.setRaycastRange
  self._mapCallback=init.mapCallback
  self.getMapCallback=level.getMapCallback
  self.setMapCallback=level.setMapCallback
  self._FOV=init.FOV
  self.getFOV=level.getFOV
  self.setFOV=level.setFOV
  self._raycastResolution=init.raycastResolution
  self.getRaycastResolution=level.getRaycastResolution
  self.setRaycastResolution=level.setRaycastResolution
  return self
end

function level:getPlayer()
  return self._player
end

function level:setPlayer(val)
  self._player=val
end

function level:getRaycastRange()
  return self._raycastRange
end

function level:setRaycastRange(val)
  self._raycastRange=val
end

function level:getMapCallback()
  return self._mapCallback
end

function level:setMapCallback(val)
  self._mapCallback=val
end

function level:getFOV()
  return self._FOV
end

function level:setFOV(val)
  self._FOV=val
end

function level:getRaycastResolution()
  return self._raycastResolution
end

function level:setRaycastResolution(val)
  self._raycastResolution=val
end

function level:getTiles()
  assert(not self._tiles_dirty,"Error: collection `self._tiles` is dirty.")
  return self._tiles
end

function level:removeTile(val)
  if val == nil then
    for i,v in pairs(self._tiles) do
      if v._remove then
        table.remove(self._tiles,i)
      end
    end
    self._tiles_dirty=nil
  else
    local found = false
    for i,v in pairs(self._tiles) do
      if v == val then
        found = true
        break
      end
    end
    assert(found,"Error: collection `self._tiles` does not contain `val`")
    val._remove=true
    self._tiles_dirty=true
  end
end

function level:addTile(val)
  assert(type(val)=="table","Error: collection `self._tiles` can only add `table`")
  table.insert(self._tiles,val)
end

function level:getEntities()
  assert(not self._entitys_dirty,"Error: collection `self._entitys` is dirty.")
  return self._entitys
end

function level:removeEntity(val)
  if val == nil then
    for i,v in pairs(self._entitys) do
      if v._remove then
        table.remove(self._entitys,i)
      end
    end
    self._entitys_dirty=nil
  else
    local found = false
    for i,v in pairs(self._entitys) do
      if v == val then
        found = true
        break
      end
    end
    assert(found,"Error: collection `self._entitys` does not contain `val`")
    val._remove=true
    self._entitys_dirty=true
  end
end

function level:addEntity(val)
  assert(type(val)=="table","Error: collection `self._entitys` can only add `table`")
  table.insert(self._entitys,val)
end

return level
