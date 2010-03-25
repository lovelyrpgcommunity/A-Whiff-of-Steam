require("lib/essential")
require("lib/math/vector2")

Map = class("Map")

Map.TILES = {                                              
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, },
}

Map.TILE_WIDTH = 155
Map.TILE_HEIGHT = 70
Map.IN_VIEW_THRESHOLD = 155
Map.TILE_MIDPOINT = Vector2:new(77, 35)
Map.TILE_TOP_VERTEX = Vector2:new(91, 0)
Map.TILE_RIGHT_VERTEX = Vector2:new(154, 46)
Map.TILE_BOTTOM_VERTEX = Vector2:new(62, 69)
Map.TILE_LEFT_VERTEX = Vector2:new(0, 22)
Map.MAX_SCALE = 2.0
Map.MIN_SCALE = 0.1
Map.RUN_SPEED = 1
Map.WALK_SPEED = 0.5
Map.SNEAK_SPEED = 0.25

Map.IMAGES = {
	gridsquare = love.graphics.newImage("resources/mapeditor/gridsquare.png"),
	tiles = {
		love.graphics.newImage("resources/images/tiles/stone_textured.png"),
		love.graphics.newImage("resources/images/tiles/grass_textured.png"),
		love.graphics.newImage("resources/images/tiles/stone_plain.png"),
		love.graphics.newImage("resources/images/tiles/grass_plain.png"),
	}
}

function Map:initialize ()
	self.size = {width=21, length=21}
	self.offset = Vector2:new(480, 120)
	self.displayControls = true
	self.editorEnabled = false
	self.canDrag = false
	self.mdp = nil -- mouse down position
	self.scale = 1
	self.selectedTile = {x=1, y=1}
end

function Map:update (dt, character)
	local speed = Map.RUN_SPEED
	if love.keyboard.isDown("lshift") then
		speed = Map.WALK_SPEED
	elseif love.keyboard.isDown("lctrl") then
		speed = Map.SNEAK_SPEED
	end
	
	-- Update the map offset
	if self.canDrag and self.mdp then
		local mx, my = love.mouse.getPosition()
		local mp = Vector2:new(mx, my)
		self.offset = self.offset - ((self.mdp - mp) / self.scale)
		self.mdp = mp
	elseif not self.editorEnabled then
		local move = (love.graphics.getHeight() / 4) * dt * speed
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
		local c = character
		local cp = c.position + Vector2:new(c.size.width/2, c.size.height/2)
		local reverse = Vector2:new(-d.x,-d.y)
		local s = self.scale
		local b = c.bounds
		local bp = b.position/s
		local p = cp + reverse
		if p.x > bp.x + b.width/s or p.x < bp.x then
			-- Move the map along the x axis
			self.offset.x = self.offset.x + d.x
		else
			-- Move the character along the x axis
			c.position.x = c.position.x + reverse.x
		end
		if p.y > bp.y + b.height/s or p.y < bp.y then
			-- Move the map along the y axis
			self.offset.y = self.offset.y + d.y
		else
			-- Move the character along the y axis
			c.position.y = c.position.y + reverse.y
		end
	end
end

function Map:draw ()
	love.graphics.push()
	love.graphics.scale(self.scale)
	local mx, my = love.mouse.getPosition()
	for i = 1,self.size.width do
		for j = 1,self.size.length do
			if self:tileIsInView(i, j) then
				if self.editorEnabled and not self.canDrag and
				   self:coordsIntersectWithTile(i, j, mx, my) then
					if self:isSelectedTile(i, j) then
						love.graphics.setColor(230,210,255)
					else
						love.graphics.setColor(255,255,255)
					end
				else
					if self:isSelectedTile(i, j) then
						love.graphics.setColor(255,255,255)
					else
						love.graphics.setColor(180,180,180)
					end
				end
				
				local x, y = self:tileToCoords(i, j)
				if Map.TILES[i] and Map.TILES[i][j] then
					love.graphics.draw(Map.IMAGES.tiles[Map.TILES[i][j]], x, y)
				else
					love.graphics.draw(Map.IMAGES.gridsquare, x, y)
					love.graphics.setColor(100,100,100)
					love.graphics.print(string.format("%s,%s",i,j), x+66, y+38)
				end
			end
		end
	end
	love.graphics.pop()
	
	if self.displayControls then
		if self.editorEnabled then
			love.graphics.setColor(255,255,255,80)
			love.graphics.rectangle("fill",10,10,200,232)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Toggle help: h",15,25)
			love.graphics.print("Toggle editor: e",15,45)
			love.graphics.print("Move: w/a/s/d or arrows",15,65)
			love.graphics.print("     or: space + mouse drag",14,80)
			love.graphics.print("Walk: lshift + move",15,100)
			love.graphics.print("Sneak: lctrl + move",15,120)
			love.graphics.print("Edit: click a tile and press",15,140)
			love.graphics.print("   `/backspace - remove tile",15,155)
			love.graphics.print("   1 - Stone (textured)",15,170)
			love.graphics.print("   2 - Grass (textured)",15,185)
			love.graphics.print("   3 - Stone (solid)",15,200)
			love.graphics.print("   4 - Grass (solid)",15,215)
			love.graphics.print("Scale: -/+",15,235)
		else
			love.graphics.setColor(255,255,255,80)
			love.graphics.rectangle("fill",10,10,200,117)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Toggle help: h",15,25)
			love.graphics.print("Toggle editor: e",15,45)
			love.graphics.print("Move: w/a/s/d or arrows",15,65)
			love.graphics.print("     or: space + mouse drag",14,80)
			love.graphics.print("Walk: lshift + move",15,100)
			love.graphics.print("Sneak: lctrl + move",15,120)
		end	

		love.graphics.printf(string.format("Scale: %s%%", math.floor(100*self.scale)), 10, 25,
			love.graphics.getWidth()-20, "right")
	end
end

function Map:tileIsInView (tx, ty)
	local s = self.scale
	local t = Map.IN_VIEW_THRESHOLD
	local tw = Map.TILE_WIDTH
	local th = Map.TILE_HEIGHT
	local cx, cy = self:tileToCoords(tx, ty)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	return cx >= (-t-tw) and cy >= (-t-th) and cx <= ((w/s)+t) and cy <= ((h/s)+t)
end

function Map:isSelectedTile (x, y, checkEditorEnabled)
	checkEditorEnabled = checkEditorEnabled or true
	if checkEditorEnabled and not self.editorEnabled then
		return false
	end
	return (checkEditorEnabled and self.editorEnabled or true) and
		   self.selectedTile and
		   self.selectedTile.x == x and
		   self.selectedTile.y == y
end

function Map:tileToCoords (tx, ty)
	local cx = self.offset.x + ((tx-1) * 63) - ((ty-1) * 93)
	local cy = self.offset.y + ((tx-1) * 47) + ((ty-1) * 23)
	return math.floor(cx), math.floor(cy)
end

-- This is inefficient.
function Map:coordsToTile (cx, cy)
	for i = 1,self.size.width do
		for j = 1,self.size.length do
			if self:coordsIntersectWithTile(i, j, cx, cy) then
				return {x=i, y=j}
			end
		end
	end
end

-- This function is gross. Gotta find a cleaner way of doing this.
function Map:coordsIntersectWithTile (px, py, cx, cy)
	local s = self.scale
	cx = cx / s
	cy = cy / s
	local mp = Map.TILE_MIDPOINT
	local t = Map.TILE_TOP_VERTEX
	local r = Map.TILE_RIGHT_VERTEX
	local b = Map.TILE_BOTTOM_VERTEX
	local l = Map.TILE_LEFT_VERTEX
	local acx, acy = self:tileToCoords(px, py) -- actual coords x and y of the tile
	local at = Vector2:new(acx+t.x, acy+t.y) -- actual mid point
	local ar = Vector2:new(acx+r.x, acy+r.y) -- actual mid point
	local ab = Vector2:new(acx+b.x, acy+b.y) -- actual mid point
	local al = Vector2:new(acx+l.x, acy+l.y) -- actual mid point
	local m = Vector2:new(cx, cy) -- the position to test
	local vt = at - m
	local vr = ar - m
	local vb = ab - m
	local vl = al - m
	local total = vt:angle(vr) + vr:angle(vb) + vb:angle(vl) + vl:angle(vt) -- the total of the angles
	return math.abs(360-total) < .1
end

function Map:mousepressed (x, y, button)
	if button == "l" then
		if self.canDrag then
			local x, y = love.mouse.getPosition()
			self.mdp = Vector2:new(x, y)
		elseif self.editorEnabled then
			local t = self:coordsToTile(x, y)
			if t then
				self.selectedTile = t
			end
		end
	end
end

function Map:mousereleased (x, y, button)
	if self.canDrag and button == "l" then
		self.mdp = nil
	end
end

function Map:keypressed (key, unicode)
	if key == "h" then
		self.displayControls = not self.displayControls
	elseif key == "e" then
		self.editorEnabled = not self.editorEnabled
	elseif key == "=" then
		if self.scale <= (Map.MAX_SCALE - 0.09) then
			self.scale = self.scale + 0.1
		end
	elseif key == "-" then
		if self.scale >= (Map.MIN_SCALE + 0.09) then
			self.scale = self.scale - 0.1
		end
	elseif key == " " then
		self.canDrag = true
	elseif self.selectedTile and Map.TILES then
		local s = self.selectedTile
		if key == "`" or key == "delete" then
			love.event.push("kp", "backspace")
		elseif key == "backspace" then
			if Map.TILES[s.x] then
				Map.TILES[s.x][s.y] = nil
			end
		else
			local byte = string.byte(key)
			if byte >= 48 and byte <= 57 then
				local tile = byte - 48 -- to get numbers 0-9
				if Map.IMAGES.tiles[tile] and Map.TILES then
					if not Map.TILES[s.x] then Map.TILES[s.x] = {} end
					Map.TILES[s.x][s.y] = tile
				end
			end
		end
	end

	if self.editorEnabled then
		local t = self.selectedTile
		local m = self.offset
		-- 63, 93
		-- 47, 23
		if key == "up" then
			if t.y-1 >= 1 then
				self.selectedTile.y = t.y - 1
				self.offset.x = self.offset.x - 93
				self.offset.y = self.offset.y + 23
			end
		end
		if key == "down" then
			if t.y+1 <= self.size.length then
				self.selectedTile.y = t.y + 1
				self.offset.x = self.offset.x + 93
				self.offset.y = self.offset.y - 23
			end
		end
		if key == "left" then
			if t.x-1 >= 1 then
				self.selectedTile.x = t.x - 1
				self.offset.x = self.offset.x + 63
				self.offset.y = self.offset.y + 47
			end
		end
		if key == "right" then
			if t.x+1 <= self.size.width then
				self.selectedTile.x = t.x + 1
				self.offset.x = self.offset.x - 63
				self.offset.y = self.offset.y - 47
			end
		end
	end
end

function Map:keyreleased (key)
	if key == " " then
		self.canDrag = false
		self.mdp = nil
	end
end
