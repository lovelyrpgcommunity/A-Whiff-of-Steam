require("lib/essential")
require("lib/math/rect")
require("lib/projection")

Character = class("Character")
Character:include(Stateful)

Character.IMAGES = {
	rectprism = love.graphics.newImage("resources/images/characters/hatter.png"),
}

local IMAGE_HEIGHT   = 128
local IMAGE_WIDTH    = 64
local FRAMES         = 13
local FRAME_DURATION = 0.06

local function createQuad(i,f)
	return love.graphics.newQuad(IMAGE_WIDTH*i,IMAGE_HEIGHT*f,IMAGE_WIDTH,IMAGE_HEIGHT,IMAGE_WIDTH*FRAMES,IMAGE_HEIGHT*8)
end

Character.QUADS = {
	rectprism = {
		se = {},
		ne = {},
		nw = {},
		sw = {},
		s  = {},
		e  = {},
		n  = {},
		w  = {},
	}
}

for i = 1,13 do
	Character.QUADS.rectprism.se[i] = createQuad(i, 7)
	Character.QUADS.rectprism.ne[i] = createQuad(i, 5)
	Character.QUADS.rectprism.nw[i] = createQuad(i, 3)
	Character.QUADS.rectprism.sw[i] = createQuad(i, 1)
	Character.QUADS.rectprism.s[i]  = createQuad(i, 0)
	Character.QUADS.rectprism.e[i]  = createQuad(i, 6)
	Character.QUADS.rectprism.n[i]  = createQuad(i, 4)
	Character.QUADS.rectprism.w[i]  = createQuad(i, 2)
end

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
	self.frame = 1
	self.next_frame = FRAME_DURATION
end

local CHARACTER_SHIFT = Vector2:new(0,IMAGE_HEIGHT-projection.vz.y)+Map.TILE_CENTRE

function Character:draw (view)
	local image = Character.IMAGES[self.image]
	local quads = Character.QUADS[self.image]
	love.graphics.push()
	love.graphics.scale(view.scale)
	local p = projection.worldToView2(self.position,view)/view.scale-CHARACTER_SHIFT
	if quads then
		local quad = quads[self.direction][self.frame]
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

		self.next_frame = self.next_frame - dt
		if self.next_frame < 0 then
			self.frame = self.frame + 1
			if self.frame == FRAMES then
				self.frame = 1
			end
			self.next_frame = FRAME_DURATION
		end
	else
		self.frame = 1
		self.next_frame = FRAME_DURATION
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

