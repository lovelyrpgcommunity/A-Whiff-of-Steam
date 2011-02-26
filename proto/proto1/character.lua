require("lib/essential")
require("lib/math/rect")
require("lib/projection")

Character = class("Character")
Character:include(Stateful)

Character.IMAGES = {
    rectprism = love.graphics.newImage("resources/images/characters/rectprism.png"),
}

Character.QUADS = {
    rectprism = {
        se = love.graphics.newQuad(0, 0, 64, 128, 512, 128),
        ne = love.graphics.newQuad(64, 0, 64, 128, 512, 128),
        nw = love.graphics.newQuad(128, 0, 64, 128, 512, 128),
        sw = love.graphics.newQuad(192, 0, 64, 128, 512, 128),
        s = love.graphics.newQuad(256, 0, 64, 128, 512, 128),
        e = love.graphics.newQuad(320, 0, 64, 128, 512, 128),
        n = love.graphics.newQuad(384, 0, 64, 128, 512, 128),
        w = love.graphics.newQuad(448, 0, 64, 128, 512, 128),
    }
}

Character.canDrag = false;

function Character:initialize ()
    self.image = "rectprism"
    self.size = {width=51, height=77}
    self.position = Vector2:new(10, 10)
    self.velocity = Vector2:new(0, 0)
    self.bounds = Rect:new(0, 0, 21-1, 21-1)
    self.direction = "sw"
end

function Character:draw (map)
    local image = Character.IMAGES[self.image]
    local quads = Character.QUADS[self.image]
    love.graphics.push()
    love.graphics.scale(self.scale)
    local coords = map.position + projection.worldToScreen({x=self.position.x,y=0,z=self.position.y})
    local x = math.floor(coords.x)
    local y = math.floor(coords.y-128+projection.vz.y-projection.vx.y)
    if quads then
        local quad = quads[self.direction]
        love.graphics.drawq(image, quad, x, y)
    else
        love.graphics.draw(image, x, y)
    end
    love.graphics.pop()
end

function Character:mousepressed (x, y, button)
    if not self.canDrag then
      x = x - 30
      y = y - 15 - self.size.height
      self.goal = Vector2:new(x, y)
      self:gotoState('MoveToPosition')
    end
end

function Character:keyreleased (key)
	if key == " " then
		self.canDrag = false
	end
end

function Character:keypressed (key, unicode)
	if key == " " then
		self.canDrag = true
	end
end

--------------------------------------------------------------------------------
-- state: Base

local Base = Character:addState('Base')

local dict = {"ne", "n", "nw", "w", "sw", "s", "se", "e"}

local function getOrientation(vec)
    dir = math.floor(4*math.atan2(-vec.y,vec.x)/math.pi+0.5)%8+1
    return dict[dir]
end

function Base:update (dt, map)
    -- adjust speed...
    local speed = Map.WALK_SPEED
    if love.keyboard.isDown("lctrl") then
        speed = Map.SNEAK_SPEED
    elseif love.keyboard.isDown("lshift") then
        speed = Map.RUN_SPEED
    end
    self.velocity = self.velocity * speed

    -- do not move outside of map...
    local temp = self.position + self.velocity
    local b = self.bounds
    if temp.x < b.position.x or temp.x > b.width then
        self.velocity.x = 0
    end
    if temp.y < b.position.y or temp.y > b.height then
        self.velocity.y = 0
    end
   
    -- finally determine direction...
    if math.abs(self.velocity.x)+math.abs(self.velocity.y)>0 then
        self.direction = getOrientation(self.velocity)
    end

    --- and position.
    self.position = self.position + self.velocity
end

--------------------------------------------------------------------------------
-- state: ArrowKeysMovement

local ArrowKeysMovement = Character:addState('ArrowKeysMovement', Base)

function ArrowKeysMovement:update (dt, map)
    self.scale = map.scale
 
    if map.editorEnabled then return end

    local move = map.BASE_SPEED * dt
    local d = Vector2:new(0,0)
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        d.y = -move
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        d.y = move
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        d.x = -move
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        d.x = move
    end
    
    if d.y ~= 0 and d.x ~= 0 then
        d.x = d.x/math.sqrt(2)
        d.y = d.y/math.sqrt(2)
    end

    self.velocity.x = (d.x-d.y)/math.sqrt(2)
    self.velocity.y = (d.x+d.y)/math.sqrt(2)

    Base.update(self, dt, map)
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
        local d = (self.goal - self.position)
        local temp = projection.screenToWorld(d)
        local angle = math.floor(8+math.atan2(temp.x,temp.z)/math.pi*4)%8*math.pi/4
        d = Vector2:new(math.sin(angle),math.cos(angle))
        d=d*map.BASE_SPEED*dt
        self.velocity=d
        Base.update(self, dt, map)
    end
end

