require("lib/game")
require("src/states/map")

function loadsave()
	if not love.filesystem.exists("save.lua") then
		--set default data
	else
		love.filesystem.load("save.lua")()
	end
end

function love.load (args)
	game = Game:new({
		map = MapState:new()
	})
	game:changeState("map")
end

function love.update (dt)
	game:update(dt)
end

function love.draw ()
	game:draw()
end

function love.keypressed (key, unicode)
	game:keypressed(key, unicode)
end

function love.keyreleased (key, unicode)
	game:keyreleased(key, unicode)
end
