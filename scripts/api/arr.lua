-- Insert into numeric or string index
local function insert(out, index, value)
    if type(index) == "number" then
        table.insert(out, index, value)
        return
    end

    if type(index) == "string" then
        out[index] = value
        return
    end

    error("Unusable index type:" .. type(index))
end

-- Run a callback across a table
local function each(arr, callback)
    for i, item in pairs(arr) do
        callback(item, i)
    end
end

-- Map across a table
local function map(arr, callback)
    local out = {}

    each(arr, function(item, i)
        insert(out, i, callback(item, i))
    end)

    return out
end

-- Create a new table from a table, stripping existing indexes
local function values(arr)
    local out = {}

    each(arr, function(item)
        table.insert(out, item)
    end)

    return out
end

-- Filter a table with a whitelisting callback
local function filter(arr, callback)
    local out = {}

    for i, item in pairs(arr) do
        if callback(item, i) then
            insert(out, i, item)
        end
    end

    return out
end

-- Filter a table with a blacklisting callback
local function reject(arr, callback)
    return filter(
        arr,
        function(item, i)
            return not callback(item, i)
        end
    )
end

-- Truth test a callback against a table
local function some(arr, callback)
    for i, item in pairs(arr) do
        if callback(item, i) then
            return true
        end
    end
    return false
end

-- Return the first table item matching a callback
local function find(arr, callback)
    for i, item in pairs(arr) do
        if callback(item, i) then
            return item, i
        end
    end
    return nil
end

-- Get the actual length of a table - including those without contiguous integer keys
local function count(arr)
    local n = 0
    for _ in pairs(arr) do
        n = n + 1
    end
    return n
end

return {
    insert = insert,
    each = each,
    map = map,
    values = values,
    filter = filter,
    reject = reject,
    some = some,
    find = find,
    count = count,
}
