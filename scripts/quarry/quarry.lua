-- DEPENDENCIES
--	: inv
--	: dig
--	: refueler
--	------------------

local tArgs = {...}
local length = tonumber(tArgs[1])
local width = tonumber(tArgs[2])
local height = tonumber(tArgs[3])
local vertical = tonumber(tArgs[4])

os.loadAPI("scripts/api/lib/inv")
os.loadAPI("scripts/quarry/refueler")
os.loadAPI("scripts/quarry/dig")

if length == nil or width == nil or height == nil then
	print("Params:")
	print("Length: int")
	print("Width: int")
	print("Height: int")
	print("Up or Down Direction: int (0 for down, 1 for up)")
	return
end

textutils.slowPrint(os.getComputerLabel() .. " used Earthquake!")

function main()
	local direction = 1
	local verticalMove = "down"
	local tracker = {w = 0, l = 0}
	local currentMove = 0
	local movesBeforeChuck = 15
	
	if vertical ~= 0 then
		verticalMove = "up"
	end

	for h = 1, height do
		for w = 1, width do
		
			dig.rAction(length-1, "forward")
			if w == width then
				if h == height then
					break
				end
				dig.action(verticalMove)
				dig.turn(1)
				dig.turn(1)
			else
				dig.turn(direction)
				dig.action("forward")
				dig.turn(direction)
				direction = direction * -1
			end
			
			currentMove = currentMove + 1
			if currentMove == movesBeforeChuck then
				checkInv()
				refueler.refuel()
				currentMove = 0
			end
			
		end
	end	
	
	local  offsetL = ((width % 2) * length) * (height % 2)
	local offsetW = ((length % 2) * width) * (height % 2)
	if height == 1 then
		offsetW = 1
	end
	returnTrip(offsetL, offsetW, verticalMove)
end

-- 	--	--
--	Dig l (width) direction
--	--	--
function run(move, dir)
  for i = 1, move do
    dig.action(dir)
  end
end

-- -- -- 
-- Return to start point
-- -- --
function returnTrip(offsetLength, offsetWidth, move)
	local flip = "down"
	if move == "down" then
		flip = "up"
	end  
	
	dig.rAction(height-1, flip)
	
	if offsetLength ~= 0 then
		dig.turn(1)
		dig.turn(1)
		dig.rAction(length-1, "forward")
	end
	
	if offsetWidth ~= 0 then
		dig.turn(1)
		dig.rAction(width-1, "forward")
		dig.turn(-1)
	end
end

-- -- -- 
-- Check inventory
-- -- --
function checkInv()
	inv.chuckUseless()
end

main()
textutils.slowPrint("It was super effective!")
