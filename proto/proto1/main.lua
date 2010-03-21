require("lib/states/fsm")
require("src/states/mapeditor")

function loadsave()
	if not love.filesystem.exists("save.lua") then
		--set default data
	else
		love.filesystem.load("save.lua")()
	end
end

function love.load (args)
	title = love.graphics.getCaption()
	game = FSM:new({
		mapeditor = MapEditorState:new()
	})
	game:changeState("mapeditor")
end

function love.update (dt)
	game:update(dt)
end

function love.draw ()
	love.graphics.setCaption(title .. " (fps " .. love.timer.getFPS() .. ")")
	game:draw()
end

function love.mousepressed (x, y, button)
	game:mousepressed(x, y, button)
end

function love.mousereleased (x, y, button)
	game:mousereleased(x, y, button)
end

function love.keypressed (key, unicode)
	game:keypressed(key, unicode)
end

function love.keyreleased (key)
	game:keyreleased(key)
end
