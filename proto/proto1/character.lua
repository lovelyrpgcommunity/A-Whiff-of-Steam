require("lib/essential")
require("lib/math/rect")

Character = class("Character", StatefulObject)

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

--------------------------------------------------------------------------------
-- state: Base

local Base = Character:addState('Base')

function Base:update (dt, map)
	-- set the direction
	local d = ""
	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		d = "n"
	end
	if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		d = "s"
	end
	if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
		d = d .. "e"
	elseif love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		d = d .. "w"
	end
	if d ~= "" then
		self.direction = d
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
		local rX = (d.x < 0) and -1 or 1
		local rY = (d.y < 0) and -1 or 1
		local moveX = 0
		local moveY = 0
		if (rX == -1 and rY == 1) or (rX == 1 and rY == -1) then
			moveX = love.graphics.getHeight() / 4 * dt
			moveY = love.graphics.getHeight() / 4 * 23 / 93 * dt
		end
		if (rX == 1 and rY == 1) or (rX == -1 and rY == -1) then
			moveX = love.graphics.getHeight() / 4 * 63 / 93 * dt
			moveY = love.graphics.getHeight() / 4 * 47 / 93 * dt
		end
		if rY == -1 then
			d.y = -moveY
		else
			d.y = moveY
		end
		if rX == -1 then
			d.x = -moveX
		else
			d.x = moveX
		end
	end
	local c = character
	local cp = c.position + Vector2:new(c.size.width/2, c.size.height/2)
	local reverse = Vector2:new(-d.x,-d.y)
	local s = self.scale
	local b = c.bounds
	local bp = b.position/s
	local p = cp + reverse
	if p.x > bp.x + b.width/s or p.x < bp.x then
		-- Move the map along the x axis
		map.velocity.x = d.x
	else
		-- Move the character along the x axis
		self.velocity.x = reverse.x
	end
	if p.y > bp.y + b.height/s or p.y < bp.y then
		-- Move the map along the y axis
		map.velocity.y = d.y
	else
		-- Move the character along the y axis
 		self.velocity.y = reverse.y
	end
	
	super.update(self, dt, map)
end

--------------------------------------------------------------------------------
-- state: MoveToPosition

local MoveToPosition = Character:addState('ClickMovement', Base)

function MoveToPosition:enterState ()
	print('moving started')
end

function MoveToPosition:exitState ()
	print('moving stopped')
end

function MoveToPosition:update (dt, map)
	local atdest = false
	if atdest then
		self:popState()
	else
		-- edit direction
	end
	
	super.update(self, dt, map)
end
