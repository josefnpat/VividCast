art = "wolf3d"
map_size = 10
draw_scale = 512/256

function map(x,y)
  if x == 1 or x == map_size then
    return 5
  end
  if y == 1 or y == map_size then
    return 4
  end
  if x == 4 and (y < 6 or y > 6) then
    return 3
  end
  return 0
end

vividcast = require "vividcast"

-- Level!
level = vividcast.level.new()
level:setMapCallback(map)
level:setRaycastRange( math.sqrt( map_size^2 + map_size^2) )
level:setRaycastResolution(0.01)

-- Tiles!
tile = vividcast.tile.new()
tile:setTexture(love.graphics.newImage(art.."/brick.png"))
level:addTile({type=5,tile=tile})

tile = vividcast.tile.new()
tile:setTexture(love.graphics.newImage(art.."/curtian.png"))
level:addTile({type=3,tile=tile})

tile = vividcast.tile.new()
tile:setTexture(love.graphics.newImage(art.."/cobble.png"))
level:addTile({type=4,tile=tile})

for _,t in pairs(level:getTiles()) do
  t.tile:getTexture():setFilter("nearest","nearest")
end

-- Enemy!
for i = 1,map_size do
  entity = vividcast.entity.new()
  entity:setX( math.random(2,map_size-1)+0.5)
  entity:setY( math.random(2,map_size-1)+0.5)
  entity:setAngle(0)
  entity:setTexture(love.graphics.newImage(art.."/enemy.png"))
  level:addEntity(entity)
end

for _,e in pairs(level:getEntities()) do
  e:getTexture():setFilter("nearest","nearest")
end

players = {}
controls = {
  {"q","w","e","a","s","d"},
  {"u","i","o","j","k","l"},
}
for i = 1,2 do
  entity = vividcast.entity.new()
  entity:setX(3)
  entity:setY(3)
  entity:setAngle(math.pi/2) -- start facing south
  entity:setTexture(love.graphics.newImage(art.."/player.png"))
  level:addEntity(entity)
  players[i]={
    entity=entity,
    controls=controls[i]
  }
end

function move(self,ix,iy)
  local x,y = self:getX()+ix,self:getY()+iy
  if level:checkCollision(x,y,0.5) == nil then
    self:setX(x)
    self:setY(y)
  end
end

function love.update(dt)

  -- RaycastResoluton
  if love.keyboard.isDown("=") then
    level:setRaycastResolution( level:getRaycastResolution() + dt/100 )
  end
  if love.keyboard.isDown("-") then
    level:setRaycastResolution( 
      math.max(level:getRaycastResolution() - dt/100,0.001)
    )
  end

  -- Player movement

  local move_speed = 3
  local turn_speed = math.pi
  for _,player in pairs(players) do
    -- Move forward
    if love.keyboard.isDown(player.controls[2]) then
      move( player.entity,
            math.cos(player.entity:getAngle())*move_speed*dt,
            math.sin(player.entity:getAngle())*move_speed*dt )
    end
    -- Move backwards
    if love.keyboard.isDown(player.controls[5]) then
      move( player.entity,
            math.cos(player.entity:getAngle()+math.pi)*move_speed*dt,
            math.sin(player.entity:getAngle()+math.pi)*move_speed*dt )
    end
    -- Turn left
    if love.keyboard.isDown(player.controls[4]) then
      player.entity:setAngle( player.entity:getAngle()-turn_speed*dt )
    end
    -- Turn right
    if love.keyboard.isDown(player.controls[6]) then
      player.entity:setAngle( player.entity:getAngle()+turn_speed*dt )
    end
    -- Strafe left
    if love.keyboard.isDown(player.controls[1]) then
      move( player.entity,
            math.cos(player.entity:getAngle()-math.pi/2)*move_speed*dt,
            math.sin(player.entity:getAngle()-math.pi/2)*move_speed*dt )
    end
    -- Strafe right
    if love.keyboard.isDown(player.controls[3]) then
      move( player.entity,
            math.cos(player.entity:getAngle()+math.pi/2)*move_speed*dt,
            math.sin(player.entity:getAngle()+math.pi/2)*move_speed*dt )
    end
  end

end

bg = love.graphics.newImage(art.."/bg.png")

function love.draw()
  love.graphics.setColor(255,255,255)
  local lx,ly,lw,lh = 32,32,
    love.graphics.getWidth()/2-64,
    love.graphics.getHeight()-64
  local w = love.graphics.getWidth()/2

  for i,player in pairs(players) do

    -- Draw a fun paralaxing background!
    love.graphics.setScissor(lx+w*(i-1),ly,lw,lh)
    love.graphics.draw(bg,
      w*(i-1)+lx-(player.entity:getAngle()/(math.pi/2)*lw)%lw,
      ly,0,lw/bg:getWidth(),lh/bg:getHeight())
    love.graphics.draw(bg,
      w*(i-1)+lx+lw-(player.entity:getAngle()/(math.pi/2)*lw)%lw,
      ly,0,lw/bg:getWidth(),lh/bg:getHeight())
    love.graphics.setScissor()

    -- Draw the level in relation to the current player
    level:setPlayer(player.entity)
    level:draw((i-1)*w+lx,ly,lw,lh,draw_scale)
  end

  love.graphics.print( love.timer.getFPS().." fps\n"..
    "Resolution: "..level:getRaycastResolution().."\n" )

end
