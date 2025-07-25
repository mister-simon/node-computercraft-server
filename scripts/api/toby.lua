local helpers = require("/scripts/api/helpers")
local go = require("/scripts/api/go")


-- Coordinates and Direction are relative to the turtle's start position
local directions = {"North", "East", "South", "West"}
local directionsLength = #directions
local directionToAxisDict = {"z", "x", "z", "x"}

local startCoords = vector.new(0, 0, 0)
local startDirection = 1
local currentAxis = 'z'
local currentDirection = 1
local currentPathIndex = 1
local path = {{vector = vector.new(0, 0, 0), direction = 1}}



-- Private functions 
-- Params: Vector, String, Int
local function updateVector(vectorObj, axis, amount) 
	vectorObj[axis] = vectorObj[axis] + amount
end

-- Params: Vector, Int
local function createNewPoint(newVector, newDirection)
	local lastVector = path[currentPathIndex].vector
	newDirection = helpers.ifNil(newDirection, currentDirection)
	newVector = helpers.ifNil(newVector, vector.new(lastVector.x, lastVector.y, lastVector.z))

	currentPathIndex = currentPathIndex + 1
	path[currentPathIndex] = {vector = newVector, direction = currentDirection}

	return path[currentPathIndex]
end

-- Params: String (x, y, z)
local function updatePathVector(axis, amount, forceNew)
	local point = path[currentPathIndex]
	local currentVector = point.vector
	amount = helpers.ifNil(amount, 1)

	if currentDirection == point.direction and forceNew ~= true then
		updateVector(point.vector, axis, amount)
	else
		currentAxis = axis
		updateVector(createNewPoint().vector, axis, amount);
	end
end

-- Params: Int
local function updateStoredDirection(turnAmount)
	local newDirection = (currentDirection + turnAmount) % directionsLength

	if newDirection == 0 then
		newDirection = directionsLength
	end
	
	currentDirection = newDirection
	return newDirection
end

-- Params: Int
local function convertByDirection(value)
	-- If Noth or West, then return positive else negative
	if currentDirection ~= 1 and currentDirection ~= 4 then
		return value * -1
	end

	return value
end



-- > On Move Callbacks
local function updateHorizontalAxis()
	currentAxis = directionToAxisDict[currentDirection]
	updatePathVector(currentAxis, convertByDirection(1))
end

local function updateHorizontalAxisNegative()
	currentAxis = directionToAxisDict[currentDirection]
	updatePathVector(currentAxis, convertByDirection(-1))
end

local function updateVerticalAxis()
	currentAxis = 'y'
	updatePathVector(currentAxis, convertByDirection(1))
end

local function updateVerticalAxisNegative()
	currentAxis = 'y'
	updatePathVector(currentAxis, convertByDirection(-1))
end



-- Exposed API / Functions
-- > Movement
-- Params: Int
function forward(distance)
	go.forward(distance, updateHorizontalAxis)
end

function back(distance)
	go.back(distance, updateHorizontalAxisNegative)
end

-- Params: Int
function up(distance)
	go.up(distance, updateVerticalAxis)
end

-- Params: Int
function down(distance)
	go.down(distance, updateVerticalAxisNegative)
end

-- Params: Int, Bool
function turnLeft(turnIterations, dumbTurn)
	go.turnLeft(turnIterations, dumbTurn)
	updateStoredDirection(turnIterations)
end

-- Params: Int, Bool
function turnRight(turnIterations, dumbTurn)
	go.turnRight(turnIterations, dumbTurn)
	updateStoredDirection(turnIterations)
end



-- > Getters
-- Params: Int
function getPathPoint(index)
	index = helpers.ifNil(index, currentPathIndex)
	return path[currentPathIndex]
end

function getPath()
	return path
end

function getStartPosition()
	return startCoords
end

function getCurrentPosition()
	return path[#path].vector
end

function getDirection()
	return currentDirection
end


return {
	forward = forward,
	back = back,
	up = up,
	down = down,
	turnLeft = turnLeft,
	turnRight = turnRight,
	getPathPoint = getPathPoint,
	getPath = getPath,
	getStartPosition = getStartPosition,
	getCurrentPosition = getCurrentPosition,
	getDirection = getDirection,
}