local settingsFile = '.settings'
local storage = 'localstorage'

local completion = require("cc.completion")
local arr = require("/scripts/api/arr")

function getLocation(tableName)
	return storage .. "." .. tableName
end

function getTable(tableName)
	return settings.get(getLocation(tableName), {})
end

function setTable(tableName, tab)
	settings.set(getLocation(tableName), tab)
	return settings.save(settingsFile)
end

function reset(tableName)
	return settings.unset(getLocation(tableName))
end

function get(tableName, key, default)
	local tab = getTable(tableName)

	if tab[key] ~= nil then
		return tab[key]
	else
		return default
	end
end

function set(tableName, key, value)
	local tab = getTable(tableName)
	tab[key] = value
	return setTable(tableName, tab)
end

function push(tableName, value)
	local tab = getTable(tableName)
	table.insert(tab, value)
	return setTable(tableName, tab)
end

function pop(tableName)
	local tab = getTable(tableName)
	local popped = table.remove(tab)
	setTable(tableName, tab)

	return popped
end

function ensure(tableName, key, suggestions)
	-- Setup
	local reader = io.read
	local validate = function(value)
		return true
	end

	if suggestions then
		validate = function(value)
			if not value then return false end

			return arr.some(suggestions, function(option)
				return option == value
			end)
		end

		reader = function()
			return read(
				nil,
				nil,
				function(text)
					return completion.choice(text, suggestions)
				end
			)
		end
	end

	-- Get current value + validate it
	local out = get(tableName, key)

	if not validate(out) then
		out = nil
		set(tableName, key, nil)
	end

	-- Update current value until a valid option is chosen
	while not get(tableName, key) do
		write("Set " .. key .. ": ")
		out = reader()

		if validate(out) then
			set(tableName, key, out)
		end
	end

	return out
end

return {
	getLocation = getLocation,
	getTable = getTable,
	setTable = setTable,
	reset = reset,
	get = get,
	set = set,
	push = push,
	pop = pop,
	ensure = ensure,
}
