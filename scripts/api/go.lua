local helpers = require("/scripts/api/helpers")
local baseMovementHandler = require("/scripts/api/lib/movement/baseMovementHandler")
local actionHelper = require("/scripts/api/lib/movement/actionHelper")

-- Handlers
local forwardHandler = baseMovementHandler.new(turtle.forward, turtle.detect, turtle.dig, turtle.attack,
	actionHelper.handleBlockage)
local backHandler = baseMovementHandler.new(turtle.back, turtle.detect, turtle.dig, turtle.attack, actionHelper.autoFail)
local upHandler = baseMovementHandler.new(turtle.up, turtle.detectUp, turtle.digUp, turtle.attackUp,
	actionHelper.handleBlockage)
local downHandler = baseMovementHandler.new(turtle.down, turtle.detectDown, turtle.digDown, turtle.attackDown,
	actionHelper.handleBlockage)


-- Params: Function, Int, Function
local function repeatMovement(movementAction, distance, callback)
	distance = helpers.ifNil(distance, 1)
	local distanceCovered = 0
	for i = 1, distance do
		if movementAction() == false then
			break
		end

		distanceCovered = i
		if callback ~= nil then
			callback()
		end
	end

	return distanceCovered
end

-- Params: Int, Function, Int (1, -1), Bool
local function repeatTurn(turnAction, turnIterations, dumbTurn)
	-- If no dumbTurn (force turning the requested amount of times), calculate how many rotations are actually needed.
	if dumbTurn ~= true then
		turnIterations = turnIterations % 4 --Number of Possible directions (N, E, S, W)
	end

	for i = 1, turnIterations do
		turnAction()
	end
end



-- Exposed API / Functions
-- Params: Int, Function
function forward(distance, onMove)
	return repeatMovement(forwardHandler.run, distance, onMove)
end

-- Params: Int, Function
function back(distance, onMove)
	distance = helpers.ifNil(distance, 1)
	local distanceCovered = repeatMovement(backHandler.run, distance, onMove)

	-- If distanceCovered is not the same as distance then moving back failed, switch handler and continue
	if distanceCovered ~= distance then
		turnLeft(2)
		distanceCovered = repeatMovement(forwardHandler.run, distance - distanceCovered, onMove)
		turnLeft(2)
	end

	return distanceCovered
end

-- Params: Int, Function
function up(distance, onMove)
	return repeatMovement(upHandler.run, distance, onMove)
end

-- Params: Int, Function
function down(distance, onMove)
	return repeatMovement(downHandler.run, distance, onMove)
end

-- Params: Int, Bool
function turnLeft(turnIterations, dumbTurn)
	repeatTurn(turtle.turnLeft, turnIterations, dumbTurn)
end

-- Params: Int, Bool
function turnRight(turnIterations, dumbTurn)
	repeatTurn(turtle.turnRight, turnIterations, dumbTurn)
end

function turnAround()
	repeatTurn(turtle.turnLeft, 2)
end

return {
	forward = forward,
	back = back,
	up = up,
	down = down,
	turnLeft = turnLeft,
	turnRight = turnRight,
	turnAround = turnAround,
}
