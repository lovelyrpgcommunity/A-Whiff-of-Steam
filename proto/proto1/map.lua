require("lib/essential")
require("lib/math/vector2")
require("projection")

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

Map.TILE_WIDTH = projection.vz.x+projection.vx.x
Map.TILE_HEIGHT = projection.vz.y-projection.vx.y
Map.MAX_SCALE = 2.0
Map.MIN_SCALE = 0.1
Map.WALK_SPEED = 1
Map.RUN_SPEED = 2
Map.SNEAK_SPEED = 0.5
Map.BASE_SPEED = 3 -- m/s in world coords

Map.IMAGES = {
	gridsquare = love.graphics.newImage("resources/mapeditor/gridsquare.png"),
	tiles = {
		love.graphics.newImage("resources/images/tiles/tile_concrete.png"),
		love.graphics.newImage("resources/images/tiles/grass_dark.png"),
		love.graphics.newImage("resources/images/tiles/grass_light.png"),
		love.graphics.newImage("resources/images/tiles/grass_fall.png"),
	}
}

function Map:initialize ()
	self.size = {width=21, length=21}
	self.position = Vector2:new(-350, 350)
	self.velocity = Vector2:new(0, 0)
	self.displayControls = true
	self.editorEnabled = false
--	self.canDrag = false
--	self.mdp = nil -- mouse down position
	self.scale = 1
	self.selectedTile = {x=1, y=1}
end

function Map:update (dt, character)
	-- Update the map position
--	if self.canDrag and self.mdp then
--		local mx, my = love.mouse.getPosition()
--		local mp = Vector2:new(mx, my)
--		self.position = self.position - ((self.mdp - mp) / self.scale)
--		self.mdp = mp	
--	end
	
	if not self.velocity:isZero() then
		-- Get the rate of movement
		local speed = Map.WALK_SPEED
		if love.keyboard.isDown("lctrl") then
			speed = Map.SNEAK_SPEED
		elseif love.keyboard.isDown("lshift") then
			speed = Map.RUN_SPEED
		end
		self.velocity = self.velocity * speed
		self.position = self.position + self.velocity
		self.velocity:zero()
	end
end

function Map:draw ()
	love.graphics.push()
	love.graphics.scale(self.scale)
	local mx, my = love.mouse.getPosition()
	for i = 1,self.size.width do
		for j = 1,self.size.length do
			if self:tileIsInView(i, j) then
				if self.editorEnabled and --not self.canDrag and
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
			love.graphics.print("Walk: lshift + move",15,85)
			love.graphics.print("Sneak: lctrl + move",15,105)
			love.graphics.print("Edit: click a tile and press",15,125)
			love.graphics.print("   `/backspace - remove tile",15,145)
			love.graphics.print("   1 - Concrete",15,160)
			love.graphics.print("   2 - Grass (dark)",15,175)
			love.graphics.print("   3 - Grass (light)",15,190)
			love.graphics.print("   4 - Grass (fall)",15,205)
			love.graphics.print("Scale: -/+",15,225)
		else
			love.graphics.setColor(255,255,255,80)
			love.graphics.rectangle("fill",10,10,200,137)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Toggle help: h",15,25)
			love.graphics.print("Toggle editor: e",15,45)
			love.graphics.print("Move: w/a/s/d or arrows",15,65)
			love.graphics.print("Walk: lshift + move",15,85)
			love.graphics.print("Sneak: lctrl + move",15,105)
			love.graphics.print("Scale: -/+",15,125)
		end	

		love.graphics.printf(string.format("Scale: %s%%", math.floor(100*self.scale)), 10, 25,
			love.graphics.getWidth()-20, "right")
	end
end

function Map:tileIsInView (tx, ty)
	local s = self.scale
	local t = Map.TILE_WIDTH
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
    local temp = self.position + projection.vx*(tx-1) + projection.vz*(ty-1)
  	return math.floor(temp.x), math.floor(temp.y)
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
	local t = projection.vx
	local r = projection.vx+projection.vz
	local b = projection.vz
	local acx, acy = self:tileToCoords(px, py) -- actual coords x and y of the tile
	local at = Vector2:new(acx+t.x, acy+t.y) -- actual mid point
	local ar = Vector2:new(acx+r.x, acy+r.y) -- actual mid point
	local ab = Vector2:new(acx+b.x, acy+b.y) -- actual mid point
	local al = Vector2:new(acx, acy) -- actual mid point
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
--		if self.canDrag then
--			local x, y = love.mouse.getPosition()
--			self.mdp = Vector2:new(x, y)
--		elseif self.editorEnabled then
		if self.editorEnabled then
			local t = self:coordsToTile(x, y)
			if t then
				self.selectedTile = t
			end
		end
	end
end

function Map:mousereleased (x, y, button)
--	if self.canDrag and button == "l" then
--		self.mdp = nil
--	end
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
--	elseif key == " " then
--		self.canDrag = true
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
		local m = self.position
		if key == "up" then
			if t.y-1 >= 1 then
				self.selectedTile.y = t.y - 1
        self.position = self.position + projection.vz
			end
		end
		if key == "down" then
			if t.y+1 <= self.size.length then
				self.selectedTile.y = t.y + 1
        self.position = self.position - projection.vz
			end
		end
		if key == "left" then
			if t.x-1 >= 1 then
				self.selectedTile.x = t.x - 1
        self.position = self.position + projection.vx
			end
		end
		if key == "right" then
			if t.x+1 <= self.size.width then
				self.selectedTile.x = t.x + 1
        self.position = self.position - projection.vx
			end
		end
	end
end

function Map:keyreleased (key)
--	if key == " " then
--		self.canDrag = false
--		self.mdp = nil
--	end
end

