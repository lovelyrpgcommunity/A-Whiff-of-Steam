require("lib/essential")
require("lib/math/vector2")
require("lib/projection")

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
Map.TILE_CENTRE = Vector2:new(
	(projection.vx.x+projection.vz.x)/2,
	(projection.vx.y+projection.vz.y)/2
)
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
	self.view = {}
	self.view.position = Vector2:new(0,0)
	self.view.scale = 1
	self.size = {width=#Map.TILES[1], length=#Map.TILES}
	self:lookAt3(self.size.width/2,self.size.length/2)
	self.velocity = Vector2:new(0, 0)
	self.displayControls = true
	self.editorEnabled = false
	self.canDrag = false
	self.mdp = nil -- mouse down position
	self.selectedTile = {
		x=math.floor(self.size.width/2)+1,
		y=math.floor(self.size.length/2)+1
	}
	self.character = Character:new()
	self.character:gotoState('ArrowKeysMovement')
end

function Map:lookAt(w)
	local v = projection.worldToView(w, self.view)
	local centre = Vector2:new(
		love.graphics.getWidth()/2,
		love.graphics.getHeight()/2
	)
	self.view.position=self.view.position+centre-v
end

function Map:lookAt2(d, level)
	self:lookAt({x=d.x,y=level or 0, z=d.y})
end

function Map:lookAt3(x, y, level)
	self:lookAt({x=x, y=level or 0, z=y})
end

function Map:lookingAt(level)
	local centre = Vector2:new(
		love.graphics.getWidth()/2,
		love.graphics.getHeight()/2
	)
	return projection.viewToWorld(centre,self.view,level)
end

function Map:update (dt)
	-- Update the map position
	if self.canDrag and self.mdp then
		local mx, my = love.mouse.getPosition()
		local mp = Vector2:new(mx, my)
		self.view.position = self.view.position + mp - self.mdp
		self.mdp = mp
	end

-- currently broken (map moving code)
--[[	if not self.velocity:isZero() then
		-- Get the rate of movement
		local speed = Map.WALK_SPEED
		if love.keyboard.isDown("lctrl") then
			speed = Map.SNEAK_SPEED
		elseif love.keyboard.isDown("lshift") then
			speed = Map.RUN_SPEED
		end
		self.velocity = self.velocity * speed
		self.view.position = self.view.position + self.velocity
		self.velocity:zero()
	end]]
	if not self.editorEnabled then
		self.character:update(dt)
	end
end

function Map:draw ()
	love.graphics.push()
	love.graphics.scale(self.view.scale)
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
					love.graphics.print(string.format("%s,%s",i,j), x+10, y+5)
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
			love.graphics.print("Run: lshift + move",15,85)
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
			love.graphics.print("Run: lshift + move",15,85)
			love.graphics.print("Sneak: lctrl + move",15,105)
			love.graphics.print("Scale: -/+",15,125)
		end	

		love.graphics.printf(string.format("Scale: %s%%", math.floor(100*self.view.scale)), 10, 25,
			love.graphics.getWidth()-20, "right")
	end
	if not self.editorEnabled then
		self.character:draw(self.view)
	end
end

function Map:tileIsInView (tx, ty)
	local s = self.view.scale
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
	local temp = projection.worldToView3(tx-1,ty-1,self.view)/self.view.scale
  	return math.floor(temp.x), math.floor(temp.y+projection.vx.y)
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
	local s = self.view.scale
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
	if not self.editorEnabled and not self.canDrag then
		self.character:mousepressed(x, y, button, self.view)
	end
end

function Map:mousereleased (x, y, button)
	if self.canDrag and button == "l" then
		self.mdp = nil
	end
end

local lastView = nil

function Map:keypressed (key, unicode)
	if key == "h" then
		self.displayControls = not self.displayControls
	elseif key == "e" then
		self.editorEnabled = not self.editorEnabled
	elseif key == "=" then
		if self.view.scale <= (Map.MAX_SCALE - 0.09) then
			local temp = self:lookingAt()
			self.view.scale = self.view.scale + 0.1
			self:lookAt(temp)
		end
	elseif key == "-" then
		if self.view.scale >= (Map.MIN_SCALE + 0.09) then
			local temp = self:lookingAt()
			self.view.scale = self.view.scale - 0.1
			self:lookAt(temp)
		end
	elseif key == " " then
		self.canDrag = true
	end

	if self.editorEnabled then
		local t = self.selectedTile
		local m = self.view.position
		if key == "up" then
			if t.y-1 >= 1 then
				self.selectedTile.y = t.y - 1
				self.view.position = self.view.position + projection.vz
			end
		end
		if key == "down" then
			if t.y+1 <= self.size.length then
				self.selectedTile.y = t.y + 1
				self.view.position = self.view.position - projection.vz
			end
		end
		if key == "left" then
			if t.x-1 >= 1 then
				self.selectedTile.x = t.x - 1
				self.view.position = self.view.position + projection.vx
			end
		end
		if key == "right" then
			if t.x+1 <= self.size.width then
				self.selectedTile.x = t.x + 1
				self.view.position = self.view.position - projection.vx
			end
		end
		if t and Map.TILES then
			if key == "`" or key == "delete" then
				love.event.push("kp", "backspace")
			elseif key == "backspace" then
				if Map.TILES[t.x] then
					Map.TILES[t.x][t.y] = nil
				end
			else
				local byte = string.byte(key)
				if byte >= 48 and byte <= 57 then
					local tile = byte - 48 -- to get numbers 0-9
					if Map.IMAGES.tiles[tile] and Map.TILES then
						if not Map.TILES[t.x] then Map.TILES[t.x] = {} end
						Map.TILES[t.x][t.y] = tile
					end
				end
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

