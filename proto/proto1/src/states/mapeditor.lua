require("lib/essential")
require("lib/states/state")
require("lib/math/vector2")

MapEditorState = class("MapEditorState", State)

MapEditorState.TILE_MIDPOINT = Vector2:new(77, 35)
MapEditorState.TILE_TOP_VERTEX = Vector2:new(91, 0)
MapEditorState.TILE_RIGHT_VERTEX = Vector2:new(154, 46)
MapEditorState.TILE_BOTTOM_VERTEX = Vector2:new(62, 69)
MapEditorState.TILE_LEFT_VERTEX = Vector2:new(0, 22)

function MapEditorState:initialize ()
	-- this is necessary because State.initialize initializes some properties
	super.initialize(self)
	self.mapsize = {width=6, height=6}
	self.mapOffset = Vector2:new(400, 100)
	self.images = {
		gridsquare = love.graphics.newImage("resources/mapeditor/images/gridsquare.gif")
	}
	self.tiles = {
		love.graphics.newImage("resources/images/tiles/stone_textured.gif"),
		love.graphics.newImage("resources/images/tiles/water_textured.gif"),
		love.graphics.newImage("resources/images/tiles/grass_textured.gif"),
		love.graphics.newImage("resources/images/tiles/stone_plain.gif"),
		love.graphics.newImage("resources/images/tiles/water_plain.gif"),
		love.graphics.newImage("resources/images/tiles/grass_plain.gif"),
	}
	self.displayHelp = true
	self.canDrag = false
	self.mdp = nil -- mouse down position
	
	self.map = "map1"
	love.filesystem.load(string.format("resources/maps/%s.lua",self.map))()
end

function MapEditorState:update (game, dt)
	-- Update the map offset
	if self.canDrag and self.mdp then
		local mx, my = love.mouse.getPosition()
		local mp = Vector2:new(mx, my)
		self.mapOffset = self.mapOffset - (self.mdp - mp)
		self.mdp = mp
	else
		if love.keyboard.isDown("up") then
			self.mapOffset.y = self.mapOffset.y - 5
		end
		if love.keyboard.isDown("down") then
			self.mapOffset.y = self.mapOffset.y + 5
		end
		if love.keyboard.isDown("left") then
			self.mapOffset.x = self.mapOffset.x - 5
		end
		if love.keyboard.isDown("right") then
			self.mapOffset.x = self.mapOffset.x + 5
		end
	end
end

function MapEditorState:draw (game)
	local mx, my = love.mouse.getPosition()
	for i = 1,self.mapsize.width do
		for j = 1,self.mapsize.height do
			if not self.canDrag and self:coordsIntersectWithTile(i, j, mx, my) then
				love.graphics.setColor(255,255,255)
			else
				love.graphics.setColor(180,180,180)
			end
			local x, y = self:tileToCoords(i, j)
			love.graphics.draw(self.images.gridsquare, x, y)
			love.graphics.setColor(100,100,100)
			love.graphics.print(string.format("%s,%s",i,j), x+66, y+38)
		end
	end
	
	if MAP then
		for i = 1,self.mapsize.width do
			if MAP[i] then
				for j = 1,self.mapsize.height do
					if MAP[i][j] then
						local x, y = self:tileToCoords(i, j)
						if not self.canDrag and self:coordsIntersectWithTile(i, j, mx, my) then
							if self:isSelectedTile(i, j) then
								love.graphics.setColor(200,170,255)
							else
								love.graphics.setColor(255,255,255)
							end
						else
							if self:isSelectedTile(i, j) then
								love.graphics.setColor(150,120,200)
							else
								love.graphics.setColor(180,180,180)
							end
						end
						love.graphics.draw(self.tiles[MAP[i][j]], x, y)
					end
				end
			end
		end
	end
	
	if self.displayHelp then
		self:drawControls(game)
	end
end

function MapEditorState:drawControls (game)
	love.graphics.setColor(255,255,255,80)
	love.graphics.rectangle("fill",10,10,200,200)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Toggle help: t",15,25)
	
	love.graphics.print("Move: arrow keys",15,45)
	love.graphics.print("     or: space + mouse drag",14,60)
	
	love.graphics.print("Quit: escape",15,80)
	
	love.graphics.print("Edit: click a tile and press",15,100)
	love.graphics.print("   delete - remove tile",15,115)
	love.graphics.print("   1 - Stone (textured)",15,130)
	love.graphics.print("   2 - Water (textured)",15,145)
	love.graphics.print("   3 - Grass (textured)",15,160)
	love.graphics.print("   4 - Stone (solid)",15,175)
	love.graphics.print("   5 - Water (solid)",15,190)
	love.graphics.print("   6 - Grass (solid)",15,205)
end

function MapEditorState:isSelectedTile (x, y)
	return self.selectedTile and
		   self.selectedTile.x == x and
		   self.selectedTile.y == y
end

function MapEditorState:tileToCoords (tx, ty)
	local cx = self.mapOffset.x + ((tx-1) * 63) - ((ty-1) * 93)
	local cy = self.mapOffset.y + ((tx-1) * 47) + ((ty-1) * 23)
	return cx, cy
end

-- This function is super inefficient
function MapEditorState:coordsToTile (cx, cy)
	for i = 1,self.mapsize.width do
		for j = 1,self.mapsize.height do
			if self:coordsIntersectWithTile(i, j, cx, cy) then
				return {x=i, y=j}
			end
		end
	end
end

-- This function is gross. Gotta find a cleaner way of doing this.
function MapEditorState:coordsIntersectWithTile (px, py, cx, cy)
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
		else
			self.selectedTile = self:coordsToTile(x, y)
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
	end
	if key == "t" then
		self.displayHelp = not self.displayHelp
	end
	if key == " " then
		self.canDrag = true
	end
	if self.selectedTile then
		local s = self.selectedTile
		print(key)
		if key == "backspace" then
			MAP[s.x][s.y] = nil
		else
			local byte = string.byte(key)
			if byte >= 48 and byte <= 57 then
				local tile = byte - 48 -- to get numbers 0-9
				if self.tiles[tile] and MAP then
					MAP[s.x][s.y] = tile
				end
			end
		end
	end
end

function MapEditorState:keyreleased (game, key, unicode)
	if key == " " then
		self.canDrag = false
		self.mdp = nil
	end
end