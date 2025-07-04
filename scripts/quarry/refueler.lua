-- DEPENDENCIES
--	: inv
--	------------------

local inv = require("/scripts/api/inv")

local refuelAt = 8000
local fuels = {
	"minecraft:coal"
}

function needsFuel()
	local level = turtle.getFuelLevel()
	if level == "unlimited" then
		return false
	else
		return level < refuelAt
	end
end

function refuel()
	if not needsFuel() then return false end

	for i=1,#fuels do
		local fuelLocations = inv.findItems(fuels[i])
		local pointer = #fuelLocations

		while needsFuel() and pointer > 0 do
			turtle.select(fuelLocations[pointer])
			turtle.refuel()
			pointer = pointer - 1
		end
	end

	return true
end

return {
	needsFuel = needsFuel,
	refuel = refuel,
}