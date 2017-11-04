require "strict"

local art = "wolf3d"
local map_size = 11
local default_resolution = 0.01

local function map(x,y)
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

local vividcast = require "vividcast"

local use_mouse = false

local playerView = 0

local level = nil
local enemy_directions = {}
local player_directions = {}
local enemies = {}
local players = {}
local controls = {
  {"a","w","d","q","s","e"},
  {"r","t","y","f","g","h"},
  {"u","i","o","j","k","l"},
  {"pageup","up","pagedown","left","down","right"}
}

local enemyPossiblePositions = {
  {xPos = 6.6, yPos = 5.5},
  {xPos = 6.6, yPos = 7.5},
  {xPos = 4.5, yPos = 5.4},
  {xPos = 6.6, yPos = 10.3},
  {xPos = 2.7, yPos = 10.3},
  {xPos = 2.7, yPos = 2.6},
  {xPos = 6.6, yPos = 2.6},
  {xPos = 8.5, yPos = 5.5},
  {xPos = 8.5, yPos = 7.5},
  {xPos = 9.4, yPos = 10.3},
  {xPos = 9.4, yPos = 2.6}
}

if #enemyPossiblePositions ~= map_size then
  assert("Amount of entries in enemyPossiblePositions Table ("..#enemyPossiblePositions..") is not equal to map_size ("..map_size..").")
end

local function calc_direction(angle)
  return math.floor(((angle+math.pi/8)/(math.pi*2))*8)%8
end

function love.load()
  -- Level!
  level = vividcast.level.new()
  level:setMapCallback(map)
  level:setRaycastRange( math.sqrt( map_size^2 + map_size^2) )
  level:setRaycastResolution(default_resolution)

  -- Tiles!
  local tile

  tile = vividcast.tile.new()
  tile:setTexture(love.graphics.newImage(art.."/brick.png"))
  level:addTile({type=5,tile=tile})

  tile = vividcast.tile.new()
  tile:setTexture(love.graphics.newImage(art.."/curtian.png"))
  level:addTile({type=3,tile=tile})

  tile = vividcast.tile.new()
  tile:setTexture(love.graphics.newImage(art.."/cobble.png"))
  tile:setColor({255,0,0})
  level:addTile({type=4,tile=tile})

  for _,t in pairs(level:getTiles()) do
    t.tile:getTexture():setFilter("nearest","nearest")
  end

  for i = 0,7 do
    enemy_directions[i]  = love.graphics.newImage(art.."/enemy_"..i..".png")
    enemy_directions[i]:setFilter("nearest","nearest")
    player_directions[i] = love.graphics.newImage(art.."/player_"..i..".png")
    player_directions[i]:setFilter("nearest","nearest")
  end

  -- Enemy!
  for _= 1,map_size do
    local entity = vividcast.entity.new()

    local color = {0,0,0}
    color[math.random(1,3)] = 255
    entity:setColor(color)
    
    local positionTableID = math.random(1,#enemyPossiblePositions)
    entity:setX(enemyPossiblePositions[positionTableID].xPos)
    entity:setY(enemyPossiblePositions[positionTableID].yPos)
    entity:setAngle(0)
    entity:setTexture(function(_, angle)
      return enemy_directions[calc_direction(angle)] end)
    level:addEntity(entity)
    table.insert(enemies,entity)
    table.remove(enemyPossiblePositions,positionTableID)
  end

  for i = 1,#controls do
    local entity = vividcast.entity.new()
    entity:setX(2+i)
    entity:setY(3)
    entity:setAngle(math.pi/2) -- start facing south
    entity:setTexture(function(_,angle)
      return player_directions[calc_direction(angle)] end)
    level:addEntity(entity)
    players[i]={
      entity=entity,
      controls=controls[i]
    }
  end

end

local function move(self,ix,iy)
  local x,y = self:getX()+ix,self:getY()+iy
  if level:checkCollision(x,y,0.5) == nil then
    self:setX(x)
    self:setY(y)
  end
end

function love.update(dt)
  local offset = love.mouse.getX() - love.graphics.getWidth() / 2
  local scale = (offset / (love.graphics.getWidth() / 2)) * 40

  if use_mouse then
    if playerView ~= 0 then
      players[playerView].entity:setAngle( players[playerView].entity:getAngle()+scale*dt )
    end
    love.mouse.setX(love.graphics.getWidth() / 2)
    love.mouse.setY(love.graphics.getHeight() / 2)
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

local bg = love.graphics.newImage(art.."/bg.png")

function love.draw()
  love.graphics.setColor(255,255,255)
  
  local padding = 8
  
  local lw = love.graphics.getWidth()/2-padding*2
  local lh = love.graphics.getHeight()/2-padding*2
  
  if playerView == 0 then
    for i,player in pairs(players) do
      local player_x = (i-1)%2
      local player_y = math.floor((i-1)/2)
      local lx = player_x*love.graphics.getWidth()/2+padding
      local ly = player_y*love.graphics.getHeight()/2+padding
      
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
      level:draw(lx,ly,lw,lh)
      
      love.graphics.print("Player "..i,(lx+padding)+(love.graphics.getWidth()/4-love.graphics.getFont():getWidth("Player "..i)/2),(ly+padding)+(love.graphics.getHeight()/4-love.graphics.getFont():getHeight("Player "..i)/2))
    end
  elseif playerView ~= 0 then
    local pid = playerView
    local player = players[pid]
    local player_x = (pid-1)%2
    local player_y = math.floor((pid-1)/2)
    
    local lw = love.graphics.getWidth() - padding*2
    local lh = love.graphics.getHeight() - padding*2
    local lx = 0 + padding
    local ly = 0 + padding
    
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
    level:draw(lx,ly,lw,lh)
    
    love.graphics.print("Player "..pid,(lw/2+padding)-(love.graphics.getFont():getWidth("Player "..pid)/2),(lh/2+padding)-(love.graphics.getFont():getHeight("Player "..pid)/2))
    love.graphics.print("X Position: "..player.entity:getX().."\nY Position: "..player.entity:getY().."\nAngle: "..player.entity:getAngle(),(lw-(love.graphics.getFont():getWidth("X Position: "..player.entity:getX().."\nY Position: "..player.entity:getY().."\nAngle: "..player.entity:getAngle()))-padding),0+(padding*2))
  end
  love.graphics.print(love.timer.getFPS().." fps | Resolution: "..level:getRaycastResolution(),0+(padding*2),0+(padding*2))
end

function love.keypressed(key)
  if key == "`" then
    if playerView ~= 0 then
      use_mouse = not use_mouse
      local state = not love.mouse.isVisible()
      love.mouse.setVisible(state)
    end
  elseif key == "escape" then
    love.event.quit()
  end
  
  for i = 1,#players do
    if key == ("f"..i) then
      if playerView == i then
        playerView = 0
      elseif playerView ~= i then
        playerView = i
      end
    end
  end
end
