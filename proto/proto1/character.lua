require("lib/essential")
require("lib/math/rect")
require("lib/projection")

Character = class("Character")
Character:include(Stateful)

Character.IMAGES = {
    rectprism = love.graphics.newImage("resources/images/characters/rectprism.png"),
}

local IMAGE_HEIGHT = 128

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

function Character:initialize ()
    self.image = "rectprism"
    self.position = Vector2:new(21/2, 21/2)
    self.velocity = Vector2:new(0, 0)
    self.bounds = Rect:new(0+0.5, 0+0.5, 21-0.5, 21-0.5)
    self.direction = "sw"
end

local SHIFT_X = Map.TILE_CENTRE_X
local SHIFT_Y = IMAGE_HEIGHT-Map.TILE_HEIGHT+Map.TILE_CENTRE_Y

function Character:draw (map)
    local image = Character.IMAGES[self.image]
    local quads = Character.QUADS[self.image]
    love.graphics.push()
    love.graphics.scale(map.scale)
    local temp = projection.worldToScreen({x=self.position.x,y=0,z=self.position.y})
    local x = math.floor(map.position.x+(temp.x-SHIFT_X)*map.scale)
    local y = math.floor(map.position.y+(temp.y-SHIFT_Y)*map.scale)
    if quads then
        local quad = quads[self.direction]
        love.graphics.drawq(image, quad, x, y)
    else
        love.graphics.draw(image, x, y)
    end
    love.graphics.pop()
end

function Character:mousepressed (x, y, button, map)
	local temp = projection.screenToWorld({
		x=x/map.scale-map.position.x,
		y=y/map.scale-map.position.y
	})
	self.goal = Vector2:new(temp.x, temp.z)
	self.goal:clamp(self.bounds)
	self:gotoState('MoveToPosition')
end

--------------------------------------------------------------------------------
-- state: Base

local Base = Character:addState('Base')

local dict = {"ne", "n", "nw", "w", "sw", "s", "se", "e"}

local function getOrientation(vec)
    dir = math.floor(4*math.atan2(-vec.y,vec.x)/math.pi+0.5)%8+1
    return dict[dir]
end

function Base:update (dt)
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
	if self.goal then self.goal.x = self.position.x end
    end
    if temp.y < b.position.y or temp.y > b.height then
        self.velocity.y = 0
	if self.goal then self.goal.y = self.position.y end
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

function ArrowKeysMovement:update (dt)
    -- determine direction in world coordinates
    local d = Vector2:new(0,0)
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        d.y = -1
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        d.y = 1
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        d.x = -1
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        d.x = 1
    end
    
    -- scale diagonals to make movement speed natual
    d:normalize()

    -- adjust speed movement
    d=d*Map.BASE_SPEED*dt

    -- rotate to alight movement to screen
    self.velocity.x = (d.x-d.y)/math.sqrt(2)
    self.velocity.y = (d.x+d.y)/math.sqrt(2)

    Base.update(self, dt)
end

--------------------------------------------------------------------------------
-- state: MoveToPosition

local MoveToPosition = Character:addState('MoveToPosition', Base)

function MoveToPosition:update (dt)
    if not self.goal then return end
    
    local p = self.position
    local testWidth = 0.1
    local test = Rect:new(p.x-testWidth/2, p.y-testWidth/2, testWidth, testWidth)
    
    if test:intersectsWithPoint(self.goal) then
	self.goal = nil
        self:gotoState('ArrowKeysMovement')
    else
        -- determine desired move
        local d = self.goal - self.position

        -- round angle to align with character images and normalize
        local angle = math.floor(8+math.atan2(d.x,d.y)/math.pi*4)%8*math.pi/4
        d = Vector2:new(math.sin(angle),math.cos(angle))

        -- adjust speed
        self.velocity=d*Map.BASE_SPEED*dt
    end
    Base.update(self, dt)
end

