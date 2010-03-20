require("lib/essential")
require("lib/states/state")
require("lib/math/vector2")

MapEditorState = class("MapEditorState", State)

MapEditorState.TILE_WIDTH = 155
MapEditorState.TILE_HEIGHT = 70
MapEditorState.IN_VIEW_THRESHOLD = MapEditorState.TILE_WIDTH
MapEditorState.TILE_MIDPOINT = Vector2:new(77, 35)
MapEditorState.TILE_TOP_VERTEX = Vector2:new(91, 0)
MapEditorState.TILE_RIGHT_VERTEX = Vector2:new(154, 46)
MapEditorState.TILE_BOTTOM_VERTEX = Vector2:new(62, 69)
MapEditorState.TILE_LEFT_VERTEX = Vector2:new(0, 22)
MapEditorState.MAX_SCALE = 2.0
MapEditorState.MIN_SCALE = 0.1

function MapEditorState:initialize ()
	-- this is necessary because State.initialize initializes some properties
	super.initialize(self)
	
	self.mapSize = {width=20, length=20} -- the number of tiles wide and long
	
	self.mapOffset = Vector2:new(480, 120)
	self.images = {
		gridsquare = love.graphics.newImage("resources/mapeditor/images/gridsquare.png")
	}
	self.tiles = {
		love.graphics.newImage("resources/images/tiles/stone_textured.png"),
		love.graphics.newImage("resources/images/tiles/grass_textured.png"),
		love.graphics.newImage("resources/images/tiles/stone_plain.png"),
		love.graphics.newImage("resources/images/tiles/grass_plain.png"),
	}
	self.editorEnabled = false
	self.canDrag = false
	self.mdp = nil -- mouse down position
	self.scale = 1
	self.selectedTile = {x=1, y=1}
	
	self.map = "map1"
	love.filesystem.load(string.format("resources/maps/%s.lua",self.map))()
end

function MapEditorState:update (game, dt)
	-- Update the map offset
	if self.canDrag and self.mdp then
		local mx, my = love.mouse.getPosition()
		local mp = Vector2:new(mx, my)
		self.mapOffset = self.mapOffset - ((self.mdp - mp) / self.scale)
		self.mdp = mp
	elseif not self.editorEnabled then
		local move = (love.graphics.getWidth() / 2) * dt
		if love.keyboard.isDown("up") then
			self.mapOffset.y = self.mapOffset.y + move
		end
		if love.keyboard.isDown("down") then
			self.mapOffset.y = self.mapOffset.y - move
		end
		if love.keyboard.isDown("left") then
			self.mapOffset.x = self.mapOffset.x + move
		end
		if love.keyboard.isDown("right") then
			self.mapOffset.x = self.mapOffset.x - move
		end
	end
end

function MapEditorState:draw (game)
	love.graphics.push()
	love.graphics.scale(self.scale)
	local mx, my = love.mouse.getPosition()
	for i = 1,self.mapSize.width do
		for j = 1,self.mapSize.length do
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
				if MAP and MAP[i] and MAP[i][j] then
					love.graphics.draw(self.tiles[MAP[i][j]], x, y)
				else
					love.graphics.draw(self.images.gridsquare, x, y)
					love.graphics.setColor(100,100,100)
					love.graphics.print(string.format("%s,%s",i,j), x+66, y+38)
				end
			end
		end
	end
	love.graphics.pop()
	
	self:drawControls(game)
end

function MapEditorState:drawControls (game)
	if self.editorEnabled then
		love.graphics.setColor(255,255,255,80)
		love.graphics.rectangle("fill",10,10,200,187)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Turn editor off: e",15,25)
		love.graphics.print("Move: arrow keys",15,45)
		love.graphics.print("     or: space + mouse drag",14,60)
		love.graphics.print("Quit: escape",15,80)
		love.graphics.print("Edit: click a tile and press",15,100)
		love.graphics.print("   backspace - remove tile",15,115)
		love.graphics.print("   1 - Stone (textured)",15,130)
		love.graphics.print("   2 - Grass (textured)",15,145)
		love.graphics.print("   3 - Stone (solid)",15,160)
		love.graphics.print("   4 - Grass (solid)",15,175)
		love.graphics.print("Scale: -/+",15,190)
	else
		love.graphics.setColor(255,255,255,80)
		love.graphics.rectangle("fill",10,10,200,57)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Turn editor on: e",15,25)
		love.graphics.print("Move: arrow keys",15,45)
		love.graphics.print("     or: space + mouse drag",14,60)
	end	
	
	love.graphics.printf(string.format("Scale: %s%%", math.floor(100*self.scale)), 10, 25,
		love.graphics.getWidth()-20, "right")
end

function MapEditorState:tileIsInView (tx, ty)
	local s = self.scale
	local t = MapEditorState.IN_VIEW_THRESHOLD
	local tw = MapEditorState.TILE_WIDTH
	local th = MapEditorState.TILE_HEIGHT
	local cx, cy = self:tileToCoords(tx, ty)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	return cx >= (-t-tw) and cy >= (-t-th) and cx <= ((w/s)+t) and cy <= ((h/s)+t)
end

function MapEditorState:isSelectedTile (x, y, checkEditorEnabled)
	checkEditorEnabled = checkEditorEnabled or true
	if checkEditorEnabled and not self.editorEnabled then
		return false
	end
	return (checkEditorEnabled and self.editorEnabled or true) and
		   self.selectedTile and
		   self.selectedTile.x == x and
		   self.selectedTile.y == y
end

function MapEditorState:tileToCoords (tx, ty)
	local cx = self.mapOffset.x + ((tx-1) * 63) - ((ty-1) * 93)
	local cy = self.mapOffset.y + ((tx-1) * 47) + ((ty-1) * 23)
	return math.floor(cx), math.floor(cy)
end

-- This function is super inefficient
function MapEditorState:coordsToTile (cx, cy)
	for i = 1,self.mapSize.width do
		for j = 1,self.mapSize.length do
			if self:coordsIntersectWithTile(i, j, cx, cy) then
				return {x=i, y=j}
			end
		end
	end
end

-- This function is gross. Gotta find a cleaner way of doing this.
function MapEditorState:coordsIntersectWithTile (px, py, cx, cy)
	local s = self.scale
	cx = cx / s
	cy = cy / s
	local mp = MapEditorState.TILE_MIDPOINT
	local t = MapEditorState.TILE_TOP_VERTEX
	local r = MapEditorState.TILE_RIGHT_VERTEX
	local b = MapEditorState.TILE_BOTTOM_VERTEX
	local l = MapEditorState.TILE_LEFT_VERTEX
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

function MapEditorState:mousepressed (game, x, y, button)
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

function MapEditorState:mousereleased (game, x, y, button)
	if self.canDrag and button == "l" then
		self.mdp = nil
	end
end

function MapEditorState:keypressed (game, key, unicode)
	if key == "escape" then
		love.event.push("q")
	elseif key == "e" then
		self.editorEnabled = not self.editorEnabled
	elseif key == "=" then
		if self.scale <= (MapEditorState.MAX_SCALE - 0.09) then
			self.scale = self.scale + 0.1
		end
	elseif key == "-" then
		if self.scale >= (MapEditorState.MIN_SCALE + 0.09) then
			self.scale = self.scale - 0.1
		end
	elseif key == " " then
		self.canDrag = true
	elseif self.selectedTile and MAP then
		local s = self.selectedTile
		if key == "backspace" then
			if MAP and MAP[s.x] then
				MAP[s.x][s.y] = nil
			end
		else
			local byte = string.byte(key)
			if byte >= 48 and byte <= 57 then
				local tile = byte - 48 -- to get numbers 0-9
				if self.tiles[tile] and MAP then
					if not MAP[s.x] then MAP[s.x] = {} end
					MAP[s.x][s.y] = tile
				end
			end
		end
	end
	
	if self.editorEnabled then
		local t = self.selectedTile
		local m = self.mapOffset
		-- 63, 93
		-- 47, 23
		if key == "up" then
			if t.y-1 >= 1 then
				self.selectedTile.y = t.y - 1
				self.mapOffset.x = self.mapOffset.x - 93
				self.mapOffset.y = self.mapOffset.y + 23
			end
		end
		if key == "down" then
			if t.y+1 <= self.mapSize.length then
				self.selectedTile.y = t.y + 1
				self.mapOffset.x = self.mapOffset.x + 93
				self.mapOffset.y = self.mapOffset.y - 23
			end
		end
		if key == "left" then
			if t.x-1 >= 1 then
				self.selectedTile.x = t.x - 1
				self.mapOffset.x = self.mapOffset.x + 63
				self.mapOffset.y = self.mapOffset.y + 47
			end
		end
		if key == "right" then
			if t.x+1 <= self.mapSize.width then
				self.selectedTile.x = t.x + 1
				self.mapOffset.x = self.mapOffset.x - 63
				self.mapOffset.y = self.mapOffset.y - 47
			end
		end
	end
end

function MapEditorState:keyreleased (game, key)
	if key == " " then
		self.canDrag = false
		self.mdp = nil
	end
end
