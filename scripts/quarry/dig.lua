-- Simple Turtle API to effectively deal with digging or moving.
local forward = {detect = turtle.detect, dig = turtle.dig, attack = turtle.attack, move = turtle.forward, duration = 0.1}
local up = {detect = turtle.detectUp, dig = turtle.digUp, attack = turtle.attackUp, move = turtle.up}
local down = {detect = turtle.detectDown, dig = turtle.digDown, attack = turtle.attackDown, move = turtle.down}

local actions = {
	forward = forward,
	up = up,
	down = down
}

local default = "forward"
local maxIterations = 50

function action(toDo, detect, destroy)
	local process = ifNil(actions[toDo], actions[default])
	local duration = ifNil(process[duration], 0.5)
	local iterations = 0
	detect = ifNil(detect, false)
	destroy = ifNil(destroy, true)
	
	local go = process.move
	if detect == true then	
		go = process.detect
	end
	
	while go() == detect do
	print(toDo)
		doAction(process, destroy, duration)
		if checkIterations(iterations) then
			break
		end
		iterations = iterations + 1	
	end
	
end

--Repeat action
function rAction(num, toDo, move, destroy)
	for i = 1, num do
		action(toDo, move, destroy)
	end
end

--Inner Loop contents
function doAction(process, destroy, duration)
	if destroy == true and process.detect() then
		process.dig()
	else
		process.attack()
		sleep(duration)
	end
end

--Check number of iterations is not equal to max number
function checkIterations(current)
	if(current == maxIterations) then
		print("Error: Iterated too many times, ensure there is fuel or block / mob in the way is destroyable")
		return true
	end
	
	return false
end

--Checks if value is nil. If it is returns newValue, so it can be assigned to that variable, else returns the currentValue
function ifNil(currentValue, newValue)
	if currentValue == nil then
		return newValue
	end
	
	return currentValue
end

function turn(direction)
	for i = 1, math.abs(direction) do
		if direction > 0 then
		  turtle.turnRight()
		else
		  turtle.turnLeft()
		end
	end
end

return {
	action = action,
	rAction = rAction,
	doAction = doAction,
	checkIterations = checkIterations,
	ifNil = ifNil,
	turn = turn,
}