require "strict"

art = "wolf3d"
map_size = 11
default_resolution = 0.01

function map(x,y)
  if x == 1 or x == map_size then
    return 5
  end
  if y == 1 or y == map_size then
    return 4
  end
  if x == 7 and (y < 6 or y > 6) then
    return 3
  end
  if x == 4 and y == 6 then
    return 3
  end
  return 0
end

vividcast = require "vividcast"

function love.load()
  -- Level!
  level = vividcast.level.new()
  level:setMapCallback(map)
  level:setRaycastRange( math.sqrt( map_size^2 + map_size^2) )
  level:setRaycastResolution(default_resolution)

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

  enemy_directions = {}
  player_directions = {}
  for i = 0,7 do
    enemy_directions[i]  = love.graphics.newImage(art.."/enemy_"..i..".png")
    enemy_directions[i]:setFilter("nearest","nearest")
    player_directions[i] = love.graphics.newImage(art.."/player_"..i..".png")
    player_directions[i]:setFilter("nearest","nearest")
  end

  -- Enemy!
  enemies = {}
  for i = 1,map_size do
    entity = vividcast.entity.new()
    entity:setX( math.random(2,map_size-1)+0.5)
    entity:setY( math.random(2,map_size-1)+0.5)
    entity:setAngle(0)
    entity:setTexture(function(this,angle)
      return enemy_directions[calc_direction(angle)] end)
    level:addEntity(entity)
    table.insert(enemies,entity)
  end

  players = {}
  controls = {
    {"a","w","d","q","s","e"},
    {"r","t","y","f","g","h"},
    {"u","i","o","j","k","l"},
    {"pageup","up","pagedown","left","down","right"}
  }

  for i = 1,#controls do
    entity = vividcast.entity.new()
    entity:setX(2+i)
    entity:setY(3)
    entity:setAngle(math.pi/2) -- start facing south
    entity:setTexture(function(self,angle)
      return player_directions[calc_direction(angle)] end)
    level:addEntity(entity)
    players[i]={
      entity=entity,
      controls=controls[i]
    }
  end

end

function calc_direction(angle)
  return math.floor(((angle+math.pi/8)/(math.pi*2))*8)%8
end

function move(self,ix,iy)
  local x,y = self:getX()+ix,self:getY()+iy
  if level:checkCollision(x,y,0.5) == nil then
    self:setX(x)
    self:setY(y)
  end
end

function love.update(dt)
  local offset = love.mouse.getX() - love.graphics.getWidth() / 2
  local scale = (offset / (love.graphics.getWidth() / 2)) * 20
  if use_mouse then
    players[1].entity:setAngle( players[1].entity:getAngle()+scale*dt )
    love.mouse.setX(love.graphics.getWidth() / 2)
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

  -- Enemy rotation
  for _,enemy in pairs(enemies) do
    enemy:setAngle( enemy:getAngle() + dt )
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

  local padding = 16

  local lw = love.graphics.getWidth()/2 - padding*2
  local lh = love.graphics.getHeight()/2 - padding*2

  for i,player in pairs(players) do

    local player_x = (i-1)%2
    local player_y = math.floor((i-1)/2)

    local lx = player_x*love.graphics.getWidth()/2 + padding
    local ly = player_y*love.graphics.getHeight()/2 + padding

    -- Draw a fun paralaxing background!
    love.graphics.setScissor(lx,ly,lw,lh)
    love.graphics.draw(bg,
      lx-(player.entity:getAngle()/(math.pi/2)*lw)%lw,
      ly,0,lw/bg:getWidth(),lh/bg:getHeight())
    love.graphics.draw(bg,
      lx+lw-(player.entity:getAngle()/(math.pi/2)*lw)%lw,
      ly,0,lw/bg:getWidth(),lh/bg:getHeight())
    love.graphics.setScissor()

    -- Draw the level in relation to the current player
    level:setPlayer(player.entity)

    local draw_scale = (love.graphics.getHeight()/2)/128
    level:draw(lx,ly,lw,lh,draw_scale)
    --love.graphics.rectangle("line",lx,ly,lw,lh)
    love.graphics.print("Player "..i,lx+padding,ly+padding)
  end

  love.graphics.print( love.timer.getFPS().." fps\n"..
    "Resolution: "..level:getRaycastResolution().."\n" )

end

use_mouse = false
function love.keypressed(key)
  if key == "`" then
    use_mouse = not use_mouse
  end
end
