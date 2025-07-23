local arr = require("/scripts/api/arr")
local coIt = require("/scripts/api/coroutine-iterator")
local itemCollection = require("/scripts/minedb/item-collection")

-- All things to do with interacting with networked storage can live here
-- Intentionally "dumb" - keeping close to inventory APIs
local function getNas(modemSide)
    local remotes = peripheral.call(modemSide, "getNamesRemote")
    local inputName, outputName
    local isStorageOnly = false

    local function setInputName(name)
        inputName = name
    end
    local function setOutputName(name)
        outputName = name
    end
    local function setStorageOnly()
        isStorageOnly = true
    end

    -- Get all inventories available on the modem's network
    local function getAll()
        return {
            peripheral.find(
                "inventory",
                function(name, inv)
                    return arr.some(remotes, function(remote)
                        return remote == name
                    end)
                end
            )
        }
    end

    -- Find the input chest peripheral
    local function getInput()
        assert(
            inputName ~= nil,
            "No input name set.\nCall setInputName with the unique inventory name.\nInventory must be on the same network!"
        )

        return arr.find(
            getAll(),
            function(inv)
                return peripheral.getName(inv) == inputName
            end
        )
    end

    -- Find the output chest peripheral
    local function getOutput()
        assert(
            outputName ~= nil,
            "No output name set.\nCall setOutputName with the unique inventory name.\nInventory must be on the same network!"
        )

        return arr.find(
            getAll(),
            function(inv)
                return peripheral.getName(inv) == outputName
            end
        )
    end

    -- Get all storage peripherals, not including IO chests
    local function getStorage()
        if isStorageOnly then
            return getAll()
        end

        local input = getInput()
        local output = getOutput()

        return arr.reject(
            getAll(),
            function(store)
                local storeName = peripheral.getName(store)
                return storeName == inputName or storeName == outputName
            end
        )
    end

    -- Creates a table of unique items in the form:
    -- { "minecraft:grass_block" = { getLocations = function(), getCount = function(), addItem = function() }, ... }
    -- getLocations() provides a table in the form:
    -- { {item = item, inv = peripheral, slot = number}, ...}
    local function list(inventories)
        inventories = inventories or getStorage()
        local items = {}

        arr.each(inventories, function(inv, i)
            arr.each(inv.list(), function(item, slot)
                if not items[item.name] then
                    items[item.name] = itemCollection()
                end

                items[item.name].addItem(inv, item, slot)
            end)
        end)

        return items
    end

    local function listInput()
        return list({ getInput() })
    end

    local function listOutput()
        return list({ getOutput() })
    end

    -- Returns an iterator
    local function listEmpty()
        local emptyCoroutine = coroutine.create(function()
            local storage = coIt.passback(getStorage)

            arr.each(storage, function(inv)
                local size = coIt.passback(inv.size)
                for slot = 1, size do
                    local details = coIt.passback(function()
                        return inv.getItemDetail(slot)
                    end)

                    if not details then
                        coroutine.yield(inv, slot)
                    end
                end
            end)
        end)

        return coIt.iterator(emptyCoroutine)
    end

    return {
        -- Basic NAS access
        getAll = getAll,

        -- Input
        setInputName = setInputName,
        getInput = getInput,
        listInput = listInput,

        -- Output
        setOutputName = setOutputName,
        getOutput = getOutput,
        listOutput = listOutput,

        -- Storage manipulation
        setStorageOnly = setStorageOnly,
        getStorage = getStorage,
        list = list,
        listEmpty = listEmpty,
    }
end

return getNas
