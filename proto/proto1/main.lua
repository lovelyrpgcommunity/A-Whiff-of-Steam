--require("lib/essential")
require("lib/math/vector2")

MAP_TILES = {                                              
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

map = {
	-- constants
	TILE_WIDTH = 155,
	TILE_HEIGHT = 70,
	IN_VIEW_THRESHOLD = 155,
	TILE_MIDPOINT = Vector2:new(77, 35),
	TILE_TOP_VERTEX = Vector2:new(91, 0),
	TILE_RIGHT_VERTEX = Vector2:new(154, 46),
	TILE_BOTTOM_VERTEX = Vector2:new(62, 69),
	TILE_LEFT_VERTEX = Vector2:new(0, 22),
	MAX_SCALE = 2.0,
	MIN_SCALE = 0.1,
	-- properties
	mapSize = {width=21, length=21},
	mapOffset = Vector2:new(480, 120),
	images = {
		gridsquare = love.graphics.newImage("resources/mapeditor/gridsquare.png")
	},
	tiles = {
		love.graphics.newImage("resources/images/tiles/stone_textured.png"),
		love.graphics.newImage("resources/images/tiles/grass_textured.png"),
		love.graphics.newImage("resources/images/tiles/stone_plain.png"),
		love.graphics.newImage("resources/images/tiles/grass_plain.png"),
	},
	displayControls = true,
	editorEnabled = false,
	canDrag = false,
	mdp = nil, -- mouse down position
	scale = 1,
	selectedTile = {x=1, y=1},
	-- functions
	tileIsInView = function (tx, ty)
		local s = map.scale
		local t = map.IN_VIEW_THRESHOLD
		local tw = map.TILE_WIDTH
		local th = map.TILE_HEIGHT
		local cx, cy = map.tileToCoords(tx, ty)
		local w = love.graphics.getWidth()
		local h = love.graphics.getHeight()
		return cx >= (-t-tw) and cy >= (-t-th) and cx <= ((w/s)+t) and cy <= ((h/s)+t)
	end,
	isSelectedTile = function (x, y, checkEditorEnabled)
		checkEditorEnabled = checkEditorEnabled or true
		if checkEditorEnabled and not map.editorEnabled then
			return false
		end
		return (checkEditorEnabled and map.editorEnabled or true) and
			   map.selectedTile and
			   map.selectedTile.x == x and
			   map.selectedTile.y == y
	end,
	tileToCoords = function (tx, ty)
		local cx = map.mapOffset.x + ((tx-1) * 63) - ((ty-1) * 93)
		local cy = map.mapOffset.y + ((tx-1) * 47) + ((ty-1) * 23)
		return math.floor(cx), math.floor(cy)
	end,
	-- This is inefficient.
	coordsToTile = function (cx, cy)
		for i = 1,map.mapSize.width do
			for j = 1,map.mapSize.length do
				if map.coordsIntersectWithTile(i, j, cx, cy) then
					return {x=i, y=j}
				end
			end
		end
	end,
	-- This function is gross. Gotta find a cleaner way of doing this.
	coordsIntersectWithTile = function (px, py, cx, cy)
		local s = map.scale
		cx = cx / s
		cy = cy / s
		local mp = map.TILE_MIDPOINT
		local t = map.TILE_TOP_VERTEX
		local r = map.TILE_RIGHT_VERTEX
		local b = map.TILE_BOTTOM_VERTEX
		local l = map.TILE_LEFT_VERTEX
		local acx, acy = map.tileToCoords(px, py) -- actual coords x and y of the tile
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
	end,
}

function loadsave()
	if not love.filesystem.exists("save.lua") then
		--set default data
	else
		love.filesystem.load("save.lua")()
	end
end

function love.load (args)
	title = love.graphics.getCaption()
end

function love.update (dt)
	-- Update the map offset
	if map.canDrag and map.mdp then
		local mx, my = love.mouse.getPosition()
		local mp = Vector2:new(mx, my)
		map.mapOffset = map.mapOffset - ((map.mdp - mp) / map.scale)
		map.mdp = mp
	elseif not map.editorEnabled then
		local move = (love.graphics.getWidth() / 2) * dt
		if love.keyboard.isDown("up") then
			map.mapOffset.y = map.mapOffset.y + move
		end
		if love.keyboard.isDown("down") then
			map.mapOffset.y = map.mapOffset.y - move
		end
		if love.keyboard.isDown("left") then
			map.mapOffset.x = map.mapOffset.x + move
		end
		if love.keyboard.isDown("right") then
			map.mapOffset.x = map.mapOffset.x - move
		end
	end
end

function love.draw ()
	love.graphics.setCaption(title .. " (fps " .. love.timer.getFPS() .. ")")
	
	love.graphics.push()
	love.graphics.scale(map.scale)
	local mx, my = love.mouse.getPosition()
	for i = 1,map.mapSize.width do
		for j = 1,map.mapSize.length do
			if map.tileIsInView(i, j) then
				if map.editorEnabled and not map.canDrag and
				   map.coordsIntersectWithTile(i, j, mx, my) then
					if map.isSelectedTile(i, j) then
						love.graphics.setColor(230,210,255)
					else
						love.graphics.setColor(255,255,255)
					end
				else
					if map.isSelectedTile(i, j) then
						love.graphics.setColor(255,255,255)
					else
						love.graphics.setColor(180,180,180)
					end
				end
				
				local x, y = map.tileToCoords(i, j)
				if MAP_TILES and MAP_TILES[i] and MAP_TILES[i][j] then
					love.graphics.draw(map.tiles[MAP_TILES[i][j]], x, y)
				else
					love.graphics.draw(map.images.gridsquare, x, y)
					love.graphics.setColor(100,100,100)
					love.graphics.print(string.format("%s,%s",i,j), x+66, y+38)
				end
			end
		end
	end
	love.graphics.pop()
	
	if map.displayControls then
		if map.editorEnabled then
			love.graphics.setColor(255,255,255,80)
			love.graphics.rectangle("fill",10,10,200,187)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Toggle help: h",15,25)
			love.graphics.print("Toggle editor: e",15,45)
			love.graphics.print("Move: arrow keys",15,65)
			love.graphics.print("     or: space + mouse drag",14,80)
			love.graphics.print("Edit: click a tile and press",15,100)
			love.graphics.print("   `/backspace - remove tile",15,115)
			love.graphics.print("   1 - Stone (textured)",15,130)
			love.graphics.print("   2 - Grass (textured)",15,145)
			love.graphics.print("   3 - Stone (solid)",15,160)
			love.graphics.print("   4 - Grass (solid)",15,175)
			love.graphics.print("Scale: -/+",15,190)
		else
			love.graphics.setColor(255,255,255,80)
			love.graphics.rectangle("fill",10,10,200,77)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("Toggle help: h",15,25)
			love.graphics.print("Toggle editor: e",15,45)
			love.graphics.print("Move: arrow keys",15,65)
			love.graphics.print("     or: space + mouse drag",14,80)
		end	

		love.graphics.printf(string.format("Scale: %s%%", math.floor(100*map.scale)), 10, 25,
			love.graphics.getWidth()-20, "right")
	end
end

function love.mousepressed (x, y, button)
	if button == "l" then
		if map.canDrag then
			local x, y = love.mouse.getPosition()
			map.mdp = Vector2:new(x, y)
		elseif map.editorEnabled then
			local t = map.coordsToTile(x, y)
			if t then
				map.selectedTile = t
			end
		end
	end
end

function love.mousereleased (x, y, button)
	if map.canDrag and button == "l" then
		map.mdp = nil
	end
end

function love.keypressed (key, unicode)
	if key == "h" then
		map.displayControls = not map.displayControls
	elseif key == "e" then
		map.editorEnabled = not map.editorEnabled
	elseif key == "=" then
		if map.scale <= (map.MAX_SCALE - 0.09) then
			map.scale = map.scale + 0.1
		end
	elseif key == "-" then
		if map.scale >= (map.MIN_SCALE + 0.09) then
			map.scale = map.scale - 0.1
		end
	elseif key == " " then
		map.canDrag = true
	elseif map.selectedTile and MAP_TILES then
		local s = map.selectedTile
		if key == "`" or key == "delete" then
			love.event.push("kp", "backspace")
		elseif key == "backspace" then
			if MAP_TILES and MAP_TILES[s.x] then
				MAP_TILES[s.x][s.y] = nil
			end
		else
			local byte = string.byte(key)
			if byte >= 48 and byte <= 57 then
				local tile = byte - 48 -- to get numbers 0-9
				if map.tiles[tile] and MAP_TILES then
					if not MAP_TILES[s.x] then MAP_TILES[s.x] = {} end
					MAP_TILES[s.x][s.y] = tile
				end
			end
		end
	end

	if map.editorEnabled then
		local t = map.selectedTile
		local m = map.mapOffset
		-- 63, 93
		-- 47, 23
		if key == "up" then
			if t.y-1 >= 1 then
				map.selectedTile.y = t.y - 1
				map.mapOffset.x = map.mapOffset.x - 93
				map.mapOffset.y = map.mapOffset.y + 23
			end
		end
		if key == "down" then
			if t.y+1 <= map.mapSize.length then
				map.selectedTile.y = t.y + 1
				map.mapOffset.x = map.mapOffset.x + 93
				map.mapOffset.y = map.mapOffset.y - 23
			end
		end
		if key == "left" then
			if t.x-1 >= 1 then
				map.selectedTile.x = t.x - 1
				map.mapOffset.x = map.mapOffset.x + 63
				map.mapOffset.y = map.mapOffset.y + 47
			end
		end
		if key == "right" then
			if t.x+1 <= map.mapSize.width then
				map.selectedTile.x = t.x + 1
				map.mapOffset.x = map.mapOffset.x - 63
				map.mapOffset.y = map.mapOffset.y - 47
			end
		end
	end
end

function love.keyreleased (key)
	if key == " " then
		map.canDrag = false
		map.mdp = nil
	end
end
