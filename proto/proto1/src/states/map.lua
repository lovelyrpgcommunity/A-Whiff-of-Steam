require("lib/essential")
require("lib/states/state")

MapState = class("MapState", State)

function MapState:initialize ()
	-- this is necessary because State.initialize initializes some properties
	super.initialize(self)
end

function MapState:update (game, dt)
	
end

function MapState:draw (game)
	
end

function MapState:keypressed (game, key, unicode)
end

function MapState:keyreleased (game, key, unicode)
end
