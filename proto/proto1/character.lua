require("lib/essential")
require("lib/math/rect")
require("lib/projection")

Character = class("Character")
Character:include(Stateful)

Character.IMAGES = {
	rectprism = love.graphics.newImage("resources/images/characters/rectprism.png"),
}

local IMAGE_HEIGHT = 128
local IMAGE_WIDTH  = 64

local function createQuad(i)
	return love.graphics.newQuad(IMAGE_WIDTH*i,0,IMAGE_WIDTH,IMAGE_HEIGHT,IMAGE_WIDTH*8,IMAGE_HEIGHT)
end

Character.QUADS = {
	rectprism = {
		se = createQuad(0),
		ne = createQuad(1),
		nw = createQuad(2),
		sw = createQuad(3),
		s  = createQuad(4),
		e  = createQuad(5),
		n  = createQuad(6),
		w  = createQuad(7),
	}
}

function Character:initialize ()
	local x0 = 0
	local y0 = 0
	local x1 = #Map.TILES[1]
	local y1 = #Map.TILES
	self.image = "rectprism"
	self.position = Vector2:new(x1/2, y1/2)
	self.velocity = Vector2:new(0, 0)
	self.bounds = Rect:new(x0+0.5, y0+0.5, x1-0.5, y1-0.5)
	self.direction = "sw"
	self.speed = Map.WALK_SPEED
end

local CHARACTER_SHIFT = Vector2:new(0,IMAGE_HEIGHT-projection.vz.y)+Map.TILE_CENTRE

function Character:draw (view)
	local image = Character.IMAGES[self.image]
	local quads = Character.QUADS[self.image]
	love.graphics.push()
	love.graphics.scale(view.scale)
	local p = projection.worldToView2(self.position,view)/view.scale-CHARACTER_SHIFT
	if quads then
		local quad = quads[self.direction]
		love.graphics.drawq(image, quad, math.floor(p.x), math.floor(p.y))
	else
		love.graphics.draw(image, math.floor(p.x), math.floor(p.y))
	end
	love.graphics.pop()
end

function Character:mousepressed (x, y, button, view)
	self.speed = Map.WALK_SPEED
	if love.keyboard.isDown("lctrl") then
		self.speed = Map.SNEAK_SPEED
	elseif love.keyboard.isDown("lshift") then
		self.speed = Map.RUN_SPEED
	end
	local temp = projection.viewToWorld2(x, y, view)
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
	-- First determine desired direction...
	if math.abs(self.velocity.x)+math.abs(self.velocity.y)>0 then
		self.direction = getOrientation(self.velocity)
	end

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

	-- finally, update direction and postion if we move.
	if math.abs(self.velocity.x)+math.abs(self.velocity.y)>0 then
		self.direction = getOrientation(self.velocity)
		self.position = self.position + self.velocity
	end
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

	-- then adjust speed
	local speed = Map.WALK_SPEED
	if love.keyboard.isDown("lctrl") then
		speed = Map.SNEAK_SPEED
	elseif love.keyboard.isDown("lshift") then
		speed = Map.RUN_SPEED
	end
	self.velocity = self.velocity * speed

	Base.update(self, dt)
end

--------------------------------------------------------------------------------
-- state: MoveToPosition

local MoveToPosition = Character:addState('MoveToPosition', Base)

function MoveToPosition:update (dt)
	if not self.goal then return end

	local p = self.position
	local testWidth = 0.1*self.speed
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
		self.velocity=d*Map.BASE_SPEED*dt*self.speed
	end
	Base.update(self, dt)
end

