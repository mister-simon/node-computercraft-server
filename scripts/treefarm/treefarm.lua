os.loadAPI('scripts/api/go.lua')
os.loadAPI('scripts/api/inv.lua')

local sapling_name = "sapling"
local bonemeal_name = "dye"
local logs_name = "log"
local fuel_name = "rod"

local refuel_req = 200
local wait_duration = 120


-- The good stuff
function main()
	print("I'm a TREE FARMING GOD!")

	-- If we have run out of materials
	if not reset() then return false end

	-- Do the stuff
	sapling()
	
	local boned = bonemeal()
	chop()

	-- If we run out of bonemeal, skip the dump and wait stages
	if not boned then
		return true
	end

	-- Do we need to refuel
	if not refuel() then return false end

	-- Stuff to probably customise
	dump()
	wait()

	return true
end

function reset()
	if not refuel() then return false end

	local hasSaplings = inv.findItem(sapling_name)
	local hasBonemeals = inv.findItem(bonemeal_name)

	if not hasSaplings or not hasBonemeals then
		if not fetchSaplingsAndBonemeals() then
			return false
		end
	end

	return true
end

-- THIS WILL NEED TO BE CUSTOMISED
function fetchSaplingsAndBonemeals()
	go.turnLeft(2)
	go.forward(3)

	local sapped = true
	local boned = true

	if not inv.findItem(sapling_name) then
		sapped = turtle.suck()
		if not sapped then print("COULD NOT GET SAPPED") end
	end

	if not inv.findItem(bonemeal_name) then
		boned = turtle.suckUp()
		if not boned then print("COULD NOT GET BONED") end
	end

	go.turnLeft(2)
	go.forward(3)

	return sapped and boned
end

-- Simple, places a sapling and returns to position
function sapling()
	go.up()

	if inv.selectItem(sapling_name) then
		turtle.place()
	end

	go.down()
end

-- Spams bonemeal and returns to position.
-- Also, returns whether it was successful or not
function bonemeal()
	-- Move underneath dirt block
	go.down()
	go.forward()


	local hasBonemeals = true
	local placedUp = false

	repeat
		hasBonemeals = inv.selectItem(bonemeal_name)
		placedUp = turtle.placeUp()
	until not hasBonemeals or not placedUp

	-- Get out from underneath dirt block
	go.back()
	go.up()

	-- Return a lack of bonemeal
	if not hasBonemeals then
		return false
	end

	return true
end

-- Chops the tree down and returns to position
function chop()
	go.up()
	go.forward()

	local upCount = 0
	while turtle.detectUp() do
		go.up(1, function() upCount = upCount + 1 end)
	end
	go.down(upCount)

	go.back()
	go.down()
end

function refuel()
	local x, y = term.getCursorPos()

	while turtle.getFuelLevel() < refuel_req + 10 do
		term.setCursorPos(1, y)
		term.clearLine()

		if inv.selectItem(fuel_name) or inv.selectItem(logs_name) then
			print("I EAT THIS FUEL!")
			turtle.refuel(1)
		else
			break
		end

		print("I HAVE FUEL: ".. tostring(turtle.getFuelLevel()) .. " / " .. tostring(refuel_req))
	end

	if turtle.getFuelLevel() > refuel_req then
		return true
	else
		print("I CAN'T MOVE! SOMEONE DIDN'T FUEL ME UP!")
		return false
	end
end

-- Dumps all the logs on the floor
function dump()
	while inv.selectItem(logs_name) do
		turtle.dropDown()
	end
	inv.selectItem(sapling_name)
end

-- Waits for a predetermined time and sucks up loose saplings
function wait()
	local x, y = term.getCursorPos()

	for i=1,wait_duration do
		term.setCursorPos(1, y)
		term.clearLine()

		write("I'M WAITING... " .. tostring(i))
		sleep(1)
		
		if turtle.suckUp() then
			term.setCursorPos(1, y)
			term.clearLine()
			print("SOMETHING LANDED ON ME!")
			print()
		end
	end

	-- Clear any saplings off the dirt block
	go.up()
	turtle.suck()
	go.down()
end

-- MAIN LOOP

local loops = 0
while main() do
	term.clear()
	term.setCursorPos(1,1)
	loops = loops + 1
	print("I ATE "..tostring(loops).." TREE(S) FOR BREAKFAST AND I'M STILL HUNGRY!")
end

-- If things fail or whatever
print("I'M BORED! I QUIT!")