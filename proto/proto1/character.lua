require("lib/essential")
require("lib/math/rect")

Character = class("Character", StatefulObject)

Character.MAX_SPEED = 500
Character.MIN_SPEED = 3

Character.IMAGES = {
  cone = love.graphics.newImage("resources/images/characters/cone.png"),
  rectprism = love.graphics.newImage("resources/images/characters/rectprism.png"),
}

Character.QUADS = {
  rectprism = {
    se = love.graphics.newQuad(0, 0, 66, 100, 432, 100),
    ne = love.graphics.newQuad(66, 0, 66, 100, 432, 100),
    nw = love.graphics.newQuad(132, 0, 66, 100, 432, 100),
    sw = love.graphics.newQuad(198, 0, 66, 100, 432, 100),
    s = love.graphics.newQuad(264, 0, 42, 100, 432, 100),
    e = love.graphics.newQuad(306, 0, 42, 100, 432, 100),
    n = love.graphics.newQuad(348, 0, 42, 100, 432, 100),
    w = love.graphics.newQuad(390, 0, 42, 100, 432, 100),
  }
}

function Character:initialize ()
  super.initialize(self)
  self.image = "rectprism"
  self.size = {width=51, height=77}
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  self.position = Vector2:new(w/2-self.size.width/2, h/2-self.size.height/2)
  self.velocity = Vector2:new(0, 0)
  self.bounds = Rect:new(200, 200, w-400, h-400)
  self.direction = "sw"
end

function Character:draw ()
  local image = Character.IMAGES[self.image]
  local quads = Character.QUADS[self.image]
  love.graphics.push()
  love.graphics.scale(self.scale)
  local x = math.floor(self.position.x)
  local y = math.floor(self.position.y)
  if quads then
    local quad = quads[self.direction]
    love.graphics.drawq(image, quad, x, y)
  else
    love.graphics.draw(image, x, y)
  end
  love.graphics.pop()
end

function Character:mousepressed (x, y, button)
  x = x - 63/2
  y = y - 23/2 - self.size.height
  self.goal = Vector2:new(x, y)
  self:gotoState('MoveToPosition')
end

--------------------------------------------------------------------------------
-- state: Base

local Base = Character:addState('Base')

-- movement constants helpers
-- to convert world to screen we do:
--  1) rotate by beta along Y
--  2) rorate by alpha along X
--  3) project to plane Z=0
-- that way to convert (x,y,z) to (x',y') we do
--  x' = cos(beta)*x + sin(beta)*z
--  y' = sin(alpha)*sin(beta)*x + cos(alpha)*y -sin(alpha)*cos(beta)*z
local alpha=math.pi/6
local beta=math.pi/7
local step=math.pi/8
local ca=math.cos(alpha)
local cb=math.cos(beta)
local sasb=math.sin(alpha)*math.sin(beta)
local tatb=math.tan(alpha)*math.tan(beta)

function Base:update (dt, map)
  -- set the direction
  x2=self.velocity.x/cb
  y2=tatb*self.velocity.x-self.velocity.y/ca
  if math.abs(x2)+math.abs(y2)>0 then
    dir=math.atan2(y2,x2)
    local d = ""
    if (dir>step) and (dir<7*step) then
      d = "n"
    elseif (dir<-step) and (dir>-7*step) then
      d = "s"
    end
    if (dir>5*step) or (dir<-5*step) then
      d = d .. "w"
    elseif (dir<3*step) and (dir>-3*step) then
      d = d .. "e"
    end
    self.direction = d
  end
  
  local p = self.position + Vector2:new(self.size.width/2, self.size.height/2) + self.velocity
  local s = self.scale
  local b = self.bounds
  local bp = b.position/s
  if p.x > bp.x + b.width/s or p.x < bp.x then
    -- Move the map along the x axis instead
    map.velocity.x = -self.velocity.x
    if self.goal then
      self.goal.x = self.goal.x - self.velocity.x
    end
    self.velocity.x = 0
  end
  if p.y > bp.y + b.height/s or p.y < bp.y then
    -- Move the map along the y axis instead
    map.velocity.y = -self.velocity.y
    if self.goal then
      self.goal.y = self.goal.y - self.velocity.y
    end
    self.velocity.y = 0
  end
  
  if not self.velocity:isZero() then
    -- Get the rate of movement
    local speed = Map.RUN_SPEED
    if love.keyboard.isDown("lctrl") then
      speed = Map.SNEAK_SPEED
    elseif love.keyboard.isDown("lshift") then
      speed = Map.WALK_SPEED
    end
    self.velocity = self.velocity * speed
    self.position = self.position + self.velocity
    self.velocity:zero()
  end
end

--------------------------------------------------------------------------------
-- state: ArrowKeysMovement

local ArrowKeysMovement = Character:addState('ArrowKeysMovement', Base)

function ArrowKeysMovement:update (dt, map)
  self.scale = map.scale
  
  if map.editorEnabled then return end
  
  local move = (love.graphics.getHeight() / 4) * dt
  local d = Vector2:new(0,0)
  if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
    d.y = move
  end
  if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
    d.y = -move
  end
  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
    d.x = move
  end
  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
    d.x = -move
  end
  
  if d.y ~= 0 and d.x ~= 0 then
    d.x = d.x/math.sqrt(2)
    d.y = d.y/math.sqrt(2)
  end

  local temp = Vector2:new(0,0)
  temp.x = -cb*d.x
  temp.y = -sasb*d.x-ca*d.y

  self.velocity.x = math.sqrt(2)/2*(temp.x+temp.y)
  self.velocity.y = math.sqrt(2)/2*(temp.y-temp.x)

  super.update(self, dt, map)
end

--------------------------------------------------------------------------------
-- state: MoveToPosition

local MoveToPosition = Character:addState('MoveToPosition', Base)

function MoveToPosition:update (dt, map)
  self.scale = map.scale
  
  if map.editorEnabled then return end
  if not self.goal then return end
  
  local p = self.position
  local test = Rect:new(p.x-5, p.y-5, 10, 10)
  
  if test:intersectsWithPoint(self.goal) then
    self:gotoState('ArrowKeysMovement')
  else
    local d = (self.goal - self.position) * dt
    local orig = Vector2:new(0,0)
    orig.x=d.x/cb
    orig.y=d.y/ca-tatb*d.x
    orig:truncate(Character.MAX_SPEED)
    orig:min(Character.MIN_SPEED)
    d.x = cb*orig.x
    d.y = sasb*orig.x+ca*orig.y
    self.velocity = d
    super.update(self, dt, map)
  end
end
