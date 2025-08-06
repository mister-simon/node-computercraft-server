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
	local reader = io.read

	if suggestions then
		reader = function()
			local out = read(nil, nil, function(text) return completion.choice(text, suggestions) end)

			-- Ensure the suggestion matches an option
			local matches = arr.some(suggestions, function(option)
				return option == out
			end)

			if not matches then
				out = ''
			end

			return out
		end
	end

	while not get(tableName, key) do
		write("Set " .. key .. ": ")
		local val = reader()
		if val ~= '' then
			set(tableName, key, val)
		end
	end
	return get(tableName, key)
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
