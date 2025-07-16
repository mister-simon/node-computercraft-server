local arr = require("/scripts/api/arr")

-- All things to do with interacting with networked storage can live here
local function getNas(modemSide)
    local remotes = peripheral.call(modemSide, "getNamesRemote")
    local inputName, outputName

    local getAll = function()
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

    local getInput = function()
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

    local getOutput = function()
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

    local getStorage = function()
        local input = getInput()
        local output = getOutput()

        return arr.reject(
            getAll(),
            function(item)
                return item == input or item == output
            end
        )
    end

    -- Currently does will not differentiate NBT data
    local list = function()
        local items = {}

        local function newItem()
            local locations = {}
            return {
                getCount = function()
                    local count = 0
                    arr.each(locations, function(location)
                        count = count + location.item.count
                    end)
                    return count
                end,
                addItem = function(inv, item, slot)
                    table.insert(locations, { item = item, inv = inv, slot = slot })
                end
            }
        end

        arr.each(getStorage(), function(inv, i)
            arr.each(inv.list(), function(item, slot)
                if not items[item.name] then
                    items[item.name] = newItem()
                end

                items[item.name].addItem(inv, item, slot)
            end)
        end)

        return items
    end

    return {
        getAll = getAll,
        setInputName = function(name) inputName = name end,
        getInput = getInput,
        setOutputName = function(name) outputName = name end,
        getOutput = getOutput,
        getStorage = getStorage,
        list = list,
    }
end


return getNas
