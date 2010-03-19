require("lib/essential")

State = class("State")

function State:initialize ()
	self.idle = false
	self.soft = false
end

function State:isIdle ()
	return self.idle
end

function State:setIdle (idle)
	self.idle = idle
end

function State:toggleIdle ()
	self.idle = not self.idle
end

function State:enter (ref) end
function State:exit (ref) end
function State:idleIn (ref) end
function State:idleOut (ref) end
function State:update (ref, dt) end
function State:draw (ref) end
function State:mousepressed (x, y, button) end
function State:mousereleased (x, y, button) end
function State:keypressed (key, unicode) end
function State:keyreleased (key, unicode) end
function State:joystickpressed (joystick, button) end
function State:joystickreleased (joystick, button) end
