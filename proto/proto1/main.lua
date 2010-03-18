function loadsave()
	if not love.filesystem.exists("save.lua") then
		--set default data
	else
		love.filesystem.load("save.lua")()
	end
end

function love.load()
end
