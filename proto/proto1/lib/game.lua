require("lib/essential")
require("lib/states/fsm")

Game = class("Game", Proxy)

function Game:initialize (states)
	self.fsm = FSM:new(self)
	self.states = states or {}
end

function Game:update (dt)
	if not self.fsm then return end
	self.fsm:update(dt)
end

function Game:draw ()
	if not self.fsm then return end
	self.fsm:draw()
end

function Game:changeState (state)
	if not self.fsm then return end
	if type(state) == "string" then
		self.fsm:changeState(self.states[state])
	else
		self.fsm:changeState(state)
	end
end

function Game:pushState (state)
	if not self.fsm then return end
	if type(state) == "string" then
		self.fsm:pushState(self.states[state])
	else
		self.fsm:pushState(state)
	end
end

function Game:popState ()
	if not self.fsm then return end
	self.fsm:popState()
end

function Game:mousepressed (x, y, button)
	if not self.fsm then return end
	self.fsm:mousepressed(x, y, button)
end

function Game:mousereleased (x, y, button)
	if not self.fsm then return end
	self.fsm:mousereleased(x, y, button)
end

function Game:keypressed (key, unicode)
	if not self.fsm then return end
	self.fsm:keypressed(key, unicode)
end

function Game:keyreleased (key, unicode)
	if not self.fsm then return end
	self.fsm:keyreleased(key, unicode)
end

function Game:joystickpressed (joystick, button)
	if not self.fsm then return end
	self.fsm:joystickpressed(joystick, button)
end

function Game:joystickreleased (joystick, button)
	if not self.fsm then return end
	self.fsm:joystickreleased(joystick, button)
end
