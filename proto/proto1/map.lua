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
Map.BORDER = 100

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

	if not self.editorEnabled then
		local temp = projection.worldToView2(self.character.position, self.view)
		if temp.x<Map.BORDER then
			self.view.position.x = self.view.position.x + Map.BORDER - temp.x
		else
			local right = love.graphics.getWidth()-Map.BORDER
			if temp.x>right then
				self.view.position.x = self.view.position.x + right - temp.x
			end
		end
		if temp.y<Map.BORDER then
			self.view.position.y = self.view.position.y + Map.BORDER - temp.y
		else
			local bottom = love.graphics.getHeight()-Map.BORDER
			if temp.y>bottom then
				self.view.position.y = self.view.position.y + bottom - temp.y
			end
		end

		self.character:update(dt)
	end
end

function Map:draw ()
	love.graphics.push()
	love.graphics.scale(self.view.scale)
	local mx, my = love.mouse.getPosition()
	local mouseover = self:coordsToTile(mx,my)
	for i = 1,self.size.width do
		for j = 1,self.size.length do
			if self:tileIsInView(i, j) then
				if self.editorEnabled and not self.canDrag and
				   mouseover.x==i and mouseover.y==j then
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
	love.graphics.setColor(255,255,255)
	love.graphics.pop()
	
	if self.displayControls then
		if self.editorEnabled then
			love.graphics.setColor(255,255,255,80)
			love.graphics.rectangle("fill",10,10,250,252)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Toggle help: h",15,25)
			love.graphics.print("Toggle editor: e",15,45)
			love.graphics.print("Move: w/a/s/d, arrows or LMB click",15,65)
			love.graphics.print("Run: lshift + move",15,85)
			love.graphics.print("Sneak: lctrl + move",15,105)
			love.graphics.print("Move map: space + LMB drag",15,125)
			love.graphics.print("Scale: -/+",15,145)
			love.graphics.print("Edit: click a tile and press",15,165)
			love.graphics.print("   backspace, delete or ` - remove tile",15,185)
			love.graphics.print("   1 - Concrete",15,200)
			love.graphics.print("   2 - Grass (dark)",15,215)
			love.graphics.print("   3 - Grass (light)",15,230)
			love.graphics.print("   4 - Grass (fall)",15,245)
		else
			love.graphics.setColor(255,255,255,80)
			love.graphics.rectangle("fill",10,10,250,157)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Toggle help: h",15,25)
			love.graphics.print("Toggle editor: e",15,45)
			love.graphics.print("Move: w/a/s/d, arrows or LMB click",15,65)
			love.graphics.print("Run: lshift + move",15,85)
			love.graphics.print("Sneak: lctrl + move",15,105)
			love.graphics.print("Move map: space + LMB drag",15,125)
			love.graphics.print("Scale: -/+",15,145)
		end	

		love.graphics.printf(string.format("Scale: %s%%", math.floor(100*self.view.scale)), 10, 25,
			love.graphics.getWidth()-20, "right")
	end
	if not self.editorEnabled then
		self.character:draw(self.view)
	end
end

function Map:tileIsInView (tx, ty)
	local temp = projection.worldToView3(tx-1,ty-1,self.view)
	return 	temp.x+Map.TILE_WIDTH*self.view.scale>0 and
		temp.x<love.graphics.getWidth() and
		temp.y+projection.vx.y*self.view.scale<love.graphics.getHeight() and
		temp.y+projection.vz.y*self.view.scale>0
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

function Map:coordsToTile (cx, cy)
	local temp = projection.viewToWorld2(cx,cy,self.view)
	return {x=math.ceil(temp.x),y=math.ceil(temp.z)}
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

local lastView = {}

function Map:keypressed (key, unicode)
	if key == "h" then
		self.displayControls = not self.displayControls
	elseif key == "e" then
		if self.editorEnabled then
			self.view.position.x = lastView.x
			self.view.position.y = lastView.y
			self.view.scale = lastView.scale
		else
			lastView.x = self.view.position.x
			lastView.y = self.view.position.y
			lastView.scale = self.view.scale
		end
		self.editorEnabled = not self.editorEnabled
	elseif key == "=" then
		if self.view.scale <= (Map.MAX_SCALE - 0.09) then
			local before = projection.worldToView2(self.character.position,self.view)
			self.view.scale = self.view.scale + 0.1
			local after = projection.worldToView2(self.character.position,self.view)
			self.view.position = self.view.position+before-after
		end
	elseif key == "-" then
		if self.view.scale >= (Map.MIN_SCALE + 0.09) then
			local before = projection.worldToView2(self.character.position,self.view)
			self.view.scale = self.view.scale - 0.1
			local after = projection.worldToView2(self.character.position,self.view)
			self.view.position = self.view.position+before-after
		end
	elseif key == " " then
		self.canDrag = true
	end

	if self.editorEnabled then
		local t = self.selectedTile
		local m = self.view.position
		if key == "up" or key=="w" then
			if t.y-1 >= 1 then
				self.selectedTile.y = t.y - 1
				self.view.position = self.view.position + projection.vz
			end
		end
		if key == "down" or key=="s" then
			if t.y+1 <= self.size.length then
				self.selectedTile.y = t.y + 1
				self.view.position = self.view.position - projection.vz
			end
		end
		if key == "left" or key=="a" then
			if t.x-1 >= 1 then
				self.selectedTile.x = t.x - 1
				self.view.position = self.view.position + projection.vx
			end
		end
		if key == "right" or key=="d" then
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

