local settingsFile = '.settings'
local storage = 'localstorage'

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

function require(tableName, key)
	while not get(tableName, key) do
		write("Set " .. key .. ": ")
		local val = io.read()
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
	require = require,
}
