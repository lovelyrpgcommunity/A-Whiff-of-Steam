require("lib/essential")
require("lib/states/state")
require("lib/math/vector2")

MapEditorState = class("MapEditorState", State)

MapEditorState.TILE_MIDPOINT = Vector2:new(77, 35)
MapEditorState.TILE_TOP_VERTEX = Vector2:new(91, 0)
MapEditorState.TILE_RIGHT_VERTEX = Vector2:new(154, 46)
MapEditorState.TILE_BOTTOM_VERTEX = Vector2:new(62, 69)
MapEditorState.TILE_LEFT_VERTEX = Vector2:new(0, 22)

local function tileToCoords (px, py, offset)
	local cx = offset.x + ((px-1) * 63) - ((py-1) * 93)
	local cy = offset.y + ((px-1) * 47) + ((py-1) * 23)
	return cx, cy
end

-- TODO
local function coordsToTile (cx, cy)
	-- local s = MapEditorState.STARTING_POINT
	-- local px = 0
	-- local py = 0
	-- return px, py
end

-- This function is gross. Gotta find a cleaner way of doing this.
local function coordsIntersectWithTile (px, py, cx, cy, offset)
	local mp = MapEditorState.TILE_MIDPOINT
	local t = MapEditorState.TILE_TOP_VERTEX
	local r = MapEditorState.TILE_RIGHT_VERTEX
	local b = MapEditorState.TILE_BOTTOM_VERTEX
	local l = MapEditorState.TILE_LEFT_VERTEX
	local acx, acy = tileToCoords(px, py, offset) -- actual coords x and y of the tile
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

function MapEditorState:initialize ()
	-- this is necessary because State.initialize initializes some properties
	super.initialize(self)
	self.mapsize = {width=5, height=5}
	self.mapOffset = Vector2:new(400, 100)
	self.images = {
		gridsquare = love.graphics.newImage("resources/mapeditor/images/gridsquare.gif")
	}
	self.canDrag = false
	self.mdp = nil -- mouse down position
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
			local x, y = tileToCoords(i, j, self.mapOffset)
			if coordsIntersectWithTile(i, j, mx, my, self.mapOffset) then
				love.graphics.setColor(255,255,255)
			else
				love.graphics.setColor(180,180,180)
			end
			love.graphics.draw(self.images.gridsquare, x, y)
			love.graphics.setColor(100,100,100)
			love.graphics.print(string.format("%s,%s",i,j), x+66, y+38)
		end
	end
end

function MapEditorState:mousepressed (game, x, y, button)
	if self.canDrag and button == "l" then
		local x, y = love.mouse.getPosition()
		self.mdp = Vector2:new(x, y)
	end
end

function MapEditorState:mousereleased (game, x, y, button)
	if self.canDrag and button == "l" then
		self.mdp = nil
	end
end

function MapEditorState:keypressed (game, key, unicode)
	if key == " " then
		self.canDrag = true
	end
end

function MapEditorState:keyreleased (game, key, unicode)
	if key == " " then
		self.canDrag = false
		self.mdp = nil
	end
end
