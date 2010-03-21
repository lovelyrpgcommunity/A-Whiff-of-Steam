require("lib/essential")

FSM = class("FSM")

function FSM:initialize (states)
	self.states = states or {}
	self.softStates = {}
end

function FSM:changeState (state)
	if type(state) == "string" then
		state = self.states[state]
	end
	
	if self.state then self.state:exit(self) end
	self.state = state
	if self.state then self.state:enter(self) end
end

function FSM:pushState (state)
	if type(state) == "string" then
		state = self.states[state]
	end
	
	if #self.softStates > 0 then
		local last = table.last(self.softStates)
		last:setIdle(true)
		last:idleIn(self)
	elseif self.state then
		self.state:setIdle(true)
		self.state:idleIn(self)
	end
	
	table.insert(self.softStates, state)
	state.soft = true
	state:enter(self)
end

function FSM:popState ()
	if #self.softStates == 0 then
		return
	end
	
	local popped = table.remove(self.softStates)
	popped:exit(self)
	popped.soft = false
	
	if #self.softStates > 0 then
		local last = table.last(self.softStates)
		last:setIdle(false)
		last:idleOut(self)
	elseif self.state then
		self.state:setIdle(false)
		self.state:idleOut(self)
	end
	
	return popped
end

function FSM:update (...)
	if self.state then
		self.state:update(self, ...)
	end
	
	-- Update the soft states.
	for _,state in ipairs(self.softStates) do
		state:update(self, ...)
	end
end

function FSM:draw (...)
	if self.state then
		self.state:draw(self, ...)
	end
	
	-- Update the soft states.
	for _,state in ipairs(self.softStates) do
		state:draw(self, ...)
	end
end

function FSM:mousepressed (...)
	if self.state then
		self.state:mousepressed(self, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:mousepressed(self, ...)
	end
end

function FSM:mousereleased (...)
	if self.state then
		self.state:mousereleased(self, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:mousereleased(self, ...)
	end
end

function FSM:keypressed (...)
	if self.state then
		self.state:keypressed(self, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:keypressed(self, ...)
	end
end

function FSM:keyreleased (...)
	if self.state then
		self.state:keyreleased(self, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:keyreleased(self, ...)
	end
end

function FSM:joystickpressed (...)
	if self.state then
		self.state:joystickpressed(self, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:joystickpressed(self, ...)
	end
end

function FSM:joystickreleased (...)
	if self.state then
		self.state:joystickreleased(self, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:joystickreleased(self, ...)
	end
end
