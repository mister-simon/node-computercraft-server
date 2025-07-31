local arr = require("/scripts/api/arr")
local gen = require("/scripts/api/generator")
local itemCollection = require("/scripts/minedb/item-collection")

local Nas = {}
Nas.__index = Nas

function Nas.new(modemSide)
    local instance = {
        modemSide = modemSide,
        inputName = nil,
        outputName = nil,
        isStorageOnly = false,
    }

    -- Get the names of attached storage
    instance.remotes = peripheral.call(modemSide, "getNamesRemote")

    return setmetatable(instance, Nas)
end

function Nas:setInputName(name)
    self.inputName = name
end

function Nas:setOutputName(name)
    self.outputName = name
end

function Nas:setStorageOnly()
    self.isStorageOnly = true
end

function Nas:getInventories()
    return {
        peripheral.find(
            "inventory",
            function(name, inv)
                return arr.some(self.remotes, function(remote)
                    return remote == name
                end)
            end
        )
    }
end

function Nas:getInput()
    assert(
        self.inputName ~= nil,
        "No input name set.\nCall setInputName with the unique inventory name.\nInventory must be on the same network!"
    )

    return arr.find(
        self:getInventories(),
        function(inv)
            return peripheral.getName(inv) == self.inputName
        end
    )
end

function Nas:getOutput()
    assert(
        self.outputName ~= nil,
        "No output name set.\nCall setOutputName with the unique inventory name.\nInventory must be on the same network!"
    )

    return arr.find(
        self:getInventories(),
        function(inv)
            return peripheral.getName(inv) == self.outputName
        end
    )
end

function Nas:getStorage()
    if self.isStorageOnly then
        return self:getInventories()
    end

    return arr.reject(
        self:getInventories(),
        function(inv)
            local invName = peripheral.getName(inv)
            return invName == self.inputName or invName == self.outputName
        end
    )
end

function Nas:list(inventories)
    inventories = inventories or self:getStorage()
    local items = {}

    arr.each(inventories, function(inv)
        arr.each(inv.list(), function(item, slot)
            if not items[item.name] then
                items[item.name] = itemCollection()
            end

            items[item.name].addItem(inv, item, slot)
        end)
    end)

    return items
end

function Nas:parallelList(inventories)
    inventories = inventories or self:getStorage()
    local items = {}

    arr.parallelEach(inventories, function(inv)
        arr.parallelEach(inv.list(), function(item, slot)
            if not items[item.name] then
                items[item.name] = itemCollection()
            end

            items[item.name].addItem(inv, item, slot)
        end)
    end)

    return items
end

function Nas:listInput()
    return self.list({ [0] = self:getInput() })
end

function Nas:listOutput()
    return self.list({ [0] = self:getOutput() })
end

function Nas:listEmpty()
    return gen.create(function(yield, exec)
        -- TODO: Is this a case where passing the instance method "self:getStorage" won't work?
        arr.each(exec(self:getStorage), function(inv)
            local size = exec(inv.size);
            local list = exec(inv.list);

            for slot = 1, size do
                if not list[slot] then
                    yield(inv, slot)
                end
            end
        end)
    end)
end

return Nas