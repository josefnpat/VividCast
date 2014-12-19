local entity = {}

-- LuaClassGen pregenerated functions

function entity.new(init)
  init = init or {}
  local self={}
  self._x=init.x
  self.getX=entity.getX
  self.setX=entity.setX
  self._y=init.y
  self.getY=entity.getY
  self.setY=entity.setY
  self._angle=init.angle
  self.getAngle=entity.getAngle
  self.setAngle=entity.setAngle
  self._texture=init.texture
  self.getTexture=entity.getTexture
  self.setTexture=entity.setTexture
  self._quad=init.quad
  self.getQuad=entity.getQuad
  self.setQuad=entity.setQuad
  self._visible=init.visible
  self.getVisible=entity.getVisible
  self.setVisible=entity.setVisible

  self:setTexture(init.texture)

  return self
end

function entity:getX()
  return self._x
end

function entity:setX(val)
  self._x=val
end

function entity:getY()
  return self._y
end

function entity:setY(val)
  self._y=val
end

function entity:getAngle()
  return self._angle
end

function entity:setAngle(val)
  self._angle=val
end

function entity:getTexture()
  return self._texture
end

function entity:setTexture(val)
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

function entity:getQuad()
  return self._quad
end

function entity:setQuad(val)
  self._quad=val
end

function entity:getVisible()
  return self._visible
end

function entity:setVisible(val)
  self._visible=val
end

return entity
