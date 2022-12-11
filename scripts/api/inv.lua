------------------------
-- Dependencies
------------------------
os.loadAPI("scripts/api/helpers.lua")

------------------------
-- Configs
------------------------
local maxSlot = 16
local useless = {
	"minecraft:cobblestone",
	"minecraft:dirt",
	"minecraft:gravel",
	"minecraft:flint"
}

------------------------
-- API FUNKS
------------------------
function getEmptySlotCount()
	local empties = 0
	for i=1,maxSlot do
		local d = turtle.getItemDetail(i)
		if d == nil then
			empties = empties + 1
		end
	end
	return empties
end

-- Will loop from current slot to the end
-- 	or until an item is found
function findItems(id, isSearch)
	local foundItems = {}

	isSearch = helpers.ifNil(isSearch, true)
	local idLower = string.lower(id)	

	local d = {}
	local dName = ""
	local found = false

	for i = 1, maxSlot do
		d = helpers.ifNil(turtle.getItemDetail(i), { name = "" })
		dName = string.lower(d.name)

		found = false

		if isSearch then
			local start = string.find(dName, idLower)

			if start ~= nil then
				found = true
			end
		else
			if dName == idLower then
				found = true
			end
		end

		if found then
			table.insert(foundItems, i)
		end
	end

	return foundItems
end

-- Find first occurence of an item
function findItem(id, isSearch)
	local foundItems = findItems(id, isSearch)

	if #foundItems == 0 then
		return nil
	else
		return foundItems[1]
	end
end

-- Select the first occurence of an item
function selectItem(id, isSearch)
	local itemIndex = findItem(id, isSearch)

	if itemIndex ~= nil then
		turtle.select(itemIndex)
		return true
	else
		return false
	end
end

-- Get the table of useless items
function getUseless()
	return useless
end

-- Set the table of useless items
function setUseless(newUseless)
	useless = newUseless
	return useless
end

-- Chuck a specific item
function chuckItem(id, isSearch)
	local foundItems = findItems(id, isSearch)

	if #foundItems == 0 then
		return false
	end

	for i=1,#foundItems do
		turtle.select(foundItems[i])
		turtle.dropUp()
	end

	return true
end

-- Chuck all the useless items
function chuckUseless()
	local found = false

	for i=1,#useless do
		local chucked = chuckItem(useless[i])

		if found == false and chucked == true then
			found = true
		end
	end

	return found
end

-- Chuck all the items
function chuckAll()
	return chuckItem("", true)
end