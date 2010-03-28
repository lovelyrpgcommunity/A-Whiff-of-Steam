require('lib/essential')
require('lib/math/vector2')

Rect = class('Rect')

Rect.DEFAULT_POSITION  = Vector2:new(0, 0)
Rect.DEFAULT_WIDTH     = 1
Rect.DEFAULT_HEIGHT    = 1

function Rect:initialize (x, y, width, height)
	self.position = (x and y) and Vector2:new(x, y) or Rect.DEFAULT_POSITION
	self.width    = width     or Rect.DEFAULT_WIDTH
	self.height   = height    or Rect.DEFAULT_HEIGHT
end

function Rect:__tostring ()
	local p = self.position
	return string.format("<Rect %f, %f, %f, %f>", p.x, p.y,
		self.width, self.height)
end

function Rect:intersectsWithPoint (x, y)
	if type("x") ~= "number" then
		y = x.y
		x = x.x
	end
	local p = self.position
	return x >= p.x and
		   y >= p.y and
		   x <= p.x + self.width and
		   y <= p.y + self.height
end

function Rect:intersectsWithRect (rect)
	error("Not implemented")
end

function Rect:intersectsWithCircle (circle)
	local p = self.position
	local hw = self.width / 2
	local hh = self.height / 2
	local dx = math.abs(circle.position.x - p.x - hw)
	local dy = math.abs(circle.position.y - p.y - hh)
	
	if dx > (hw + circle.radius) then return false end
	if dy > (hh + circle.radius) then return false end
	
	if dx <= hw then return true end
	if dy <= hh then return true end
	
	local cd = ((dx - hw) ^ 2) + ((dy - hh) ^ 2)
	return cd <= circle.radius ^ 2
end
