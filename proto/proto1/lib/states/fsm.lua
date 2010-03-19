require("lib/essential")

FSM = class("FSM")

function FSM:initialize (ref)
	self.ref = ref
	self.softStates = {}
end

function FSM:changeState (state)
	if self.state then self.state:exit(self.ref) end
	self.state = state
	if self.state then self.state:enter(self.ref) end
end

function FSM:pushState (state)
	if #self.softStates > 0 then
		local last = table.last(self.softStates)
		last:setIdle(true)
		last:idleIn(self.ref)
	elseif self.state then
		self.state:setIdle(true)
		self.state:idleIn(self.ref)
	end
	
	state.soft = true
	table.insert(self.softStates, state)
	state:enter(self.ref)
end

function FSM:popState ()
	if #self.softStates == 0 then
		return
	end
	
	local popped = table.remove(self.softStates)
	popped.soft = false
	popped:exit(self.ref)
	
	if #self.softStates > 0 then
		local last = table.last(self.softStates)
		last:setIdle(false)
		last:idleOut(self.ref)
	elseif self.state then
		self.state:setIdle(false)
		self.state:idleOut(self.ref)
	end
end

function FSM:update (...)
	if self.state then
		self.state:update(self.ref, ...)
	end
	
	-- Update the soft states.
	for _,state in ipairs(self.softStates) do
		state:update(self.ref, ...)
	end
end

function FSM:draw (...)
	if self.state then
		self.state:draw(self.ref, ...)
	end
	
	-- Update the soft states.
	for _,state in ipairs(self.softStates) do
		state:draw(self.ref, ...)
	end
end

function FSM:mousepressed (...)
	if self.state then
		self.state:mousepressed(self.ref, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:mousepressed(self.ref, ...)
	end
end

function FSM:mousereleased (...)
	if self.state then
		self.state:mousereleased(self.ref, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:mousereleased(self.ref, ...)
	end
end

function FSM:keypressed (...)
	if self.state then
		self.state:keypressed(self.ref, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:keypressed(self.ref, ...)
	end
end

function FSM:keyreleased (...)
	if self.state then
		self.state:keyreleased(self.ref, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:keyreleased(self.ref, ...)
	end
end

function FSM:joystickpressed (...)
	if self.state then
		self.state:joystickpressed(self.ref, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:joystickpressed(self.ref, ...)
	end
end

function FSM:joystickreleased (...)
	if self.state then
		self.state:joystickreleased(self.ref, ...)
	end
	
	for _,state in ipairs(self.softStates) do
		state:joystickreleased(self.ref, ...)
	end
end
