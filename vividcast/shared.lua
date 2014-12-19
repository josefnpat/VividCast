local shared = {}

function shared:setTexture(val)
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

return shared
