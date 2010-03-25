require("lib/essential")
require("lib/math/rect")

Character = class("Character")

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
	self.image = "rectprism"
	self.size = {width=51, height=77}
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	self.position = Vector2:new(w/2-self.size.width/2, h/2-self.size.height/2)
	self.bounds = Rect:new(200, 200, w-400, h-400)
	self.direction = "sw"
end

function Character:update (dt, map)
	self.scale = map.scale
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
