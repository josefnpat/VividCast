local tile = {}

-- LuaClassGen pregenerated functions

function tile.new(init)
  init = init or {}
  local self={}
  self._texture=init.texture
  self.getTexture=tile.getTexture
  self.setTexture=tile.setTexture
  self._quad=init.quad
  self.getQuad=tile.getQuad
  self.setQuad=tile.setQuad

  self:setTexture(init.texture)

  return self
end

function tile:getTexture()
  return self._texture
end

function tile:setTexture(val)
  self._texture=val
  if val then
    local q = {}
    for i = 1,val:getWidth() do
      table.insert(q,
        love.graphics.newQuad(i,1,1,val:getHeight(),
          val:getWidth(),val:getHeight()))
    end
    self:setQuad(q)
  end
end

function tile:getQuad()
  return self._quad
end

function tile:setQuad(val)
  self._quad=val
end

return tile
