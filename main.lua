vividcast = require "vividcast"

art = "wolf3d"
map_size = 30

function map(x,y)
  if x == 1 or x == map_size then
    return 5
  end
  if y == 1 or y == map_size then
    return 4
  end
  if x == 4 and (y < 6 or y > 7) then
    return 3
  end
  return 0
end

-- Level!
level = vividcast.level.new()
level:setMapCallback(map)
level:setRaycastRange( math.sqrt( map_size^2 + map_size^2) )
level:setRaycastResolution(0.01)
level:setFOV(math.pi*0.25)

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
entity = vividcast.entity.new()
entity:setX(2)
entity:setY(2)
entity:setAngle(0)
entity:setTexture(love.graphics.newImage("enemy.png"))

level:addEntity(entity)

-- Player!
player = vividcast.entity.new()
player:setX(3)
player:setY(3)
player:setAngle(math.pi/2) -- start facing south
player:setTexture(love.graphics.newImage("player.png"))

level:addEntity(player)
level:setPlayer(player)

function move(ix,iy)
  local x,y = player:getX()+ix,player:getY()+iy
  if level:getMapCallback()(math.floor(x),math.floor(y)) == 0 then
    player:setX(x)
    player:setY(y)
  end
end

function love.update(dt)
  local speed = 3

  -- Move
  if love.keyboard.isDown("w") then
    move( math.cos(player:getAngle())*speed*dt,
          math.sin(player:getAngle())*speed*dt )
  end
  if love.keyboard.isDown("s") then
    move( math.cos(player:getAngle()+math.pi)*speed*dt,
          math.sin(player:getAngle()+math.pi)*speed*dt )
  end
  -- Turn
  if love.keyboard.isDown("a") then
    player:setAngle( player:getAngle() - dt*math.pi )
  end
  if love.keyboard.isDown("d") then
    player:setAngle( player:getAngle() + dt*math.pi )
  end
  -- Straife
  if love.keyboard.isDown("q") then
    move( math.cos(player:getAngle()-math.pi/2)*speed*dt,
          math.sin(player:getAngle()-math.pi/2)*speed*dt )
  end
  if love.keyboard.isDown("e") then
    move( math.cos(player:getAngle()+math.pi/2)*speed*dt,
          math.sin(player:getAngle()+math.pi/2)*speed*dt )
  end

  -- FOV
  if love.keyboard.isDown("]") then
    level:setFOV( level:getFOV() + dt )
  end
  if love.keyboard.isDown("[") then
    level:setFOV( level:getFOV() - dt )
  end

  -- RaycastResoluton
  if love.keyboard.isDown("=") then
    level:setRaycastResolution( level:getRaycastResolution() + dt/100 )
  end
  if love.keyboard.isDown("-") then
    level:setRaycastResolution( 
      math.max(level:getRaycastResolution() - dt/100,0.001)
    )
  end

end

bg = love.graphics.newImage(art.."/bg.png")

function love.draw()
  love.graphics.setColor(255,255,255)
  local lx,ly,lw,lh = 32,32,
    love.graphics.getWidth()-64,
    love.graphics.getHeight()-64

  -- Draw a fun paralaxing background!
  love.graphics.setScissor(lx,ly,lw,lh)
  love.graphics.draw(bg,
    lx-(player:getAngle()/(math.pi/2)*lw)%lw,
    ly,0,lw/bg:getWidth(),lh/bg:getHeight())
  love.graphics.draw(bg,
    lx+lw-(player:getAngle()/(math.pi/2)*lw)%lw,
    ly,0,lw/bg:getWidth(),lh/bg:getHeight())
  love.graphics.setScissor()

  local lolscale = love.graphics.getHeight()/256

  level:draw(lx,ly,lw,lh,lolscale)
  love.graphics.print( love.timer.getFPS().." fps\n"..
    "FOV: "..level:getFOV().." rad\n"..
    "Resolution: "..level:getRaycastResolution().."\n" ..
    "Entity is ".. (#entity:getVisible()>0 and "" or "not ") .. "visible.")

  -- Show a compass
  love.graphics.setColor(255,255,255)
  love.graphics.arc("line",64,64,32,
    player:getAngle()-0.1+math.pi,
    player:getAngle()+0.1+math.pi)
  love.graphics.setColor(255,0,0)
  love.graphics.arc("fill",64,64,32,
    player:getAngle()-0.1,
    player:getAngle()+0.1)

end
