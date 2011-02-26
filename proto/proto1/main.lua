require("map")
require("character")

function love.load (args)
	title = love.graphics.getCaption()
	map = Map:new()
	character = Character:new(10.5,10.5) -- map is 21x21 in world coords
	map:addCharacter(character)
	character:gotoState('ArrowKeysMovement')
end

function love.update (dt)
	map:update(dt)
end

function love.draw ()
	love.graphics.setCaption(title .. " (fps " .. love.timer.getFPS() .. ")")
	map:draw()
end

function love.mousepressed (x, y, button)
	map:mousepressed(x, y, button)
end

function love.mousereleased (x, y, button)
	map:mousereleased(x, y, button)
end

function love.keypressed (key, unicode)
	map:keypressed(key, unicode)
end

function love.keyreleased (key)
	map:keyreleased(key)
end

