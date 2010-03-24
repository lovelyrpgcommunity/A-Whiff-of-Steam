require("lib/essential")

Character = class("Character")

Character.IMAGES = {
	cone = love.graphics.newImage("resources/images/characters/cone.png")
}

function Character:initialize ()
	self.size = {width=51, height=77}
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	self.position = Vector2:new(w/2-self.size.width/2, h/2-self.size.height/2)
end

function Character:update (dt, map)
	self.scale = map.scale
end

function Character:draw ()
	local p = self.position
	local image = Character.IMAGES.cone
	love.graphics.push()
	love.graphics.scale(self.scale)
	love.graphics.draw(image, p.x, p.y)
	love.graphics.pop()
end
