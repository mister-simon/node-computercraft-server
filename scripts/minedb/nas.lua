-- local pp = require "cc.pretty".pretty_print
local arr = require("/scripts/api/arr")
local gen = require("/scripts/api/generator")
local itemCollection = require("/scripts/minedb/item-collection")

--- @class Nas
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

    local todo = {}
    local items = {}

    for i, inv in pairs(inventories) do
        table.insert(todo, function()
            arr.each(inv.list(), function(item, slot)
                if not items[item.name] then
                    items[item.name] = itemCollection()
                end

                items[item.name].addItem(inv, item, slot)
            end)
        end)
    end

    parallel.waitForAll(table.unpack(todo))

    return items
end

function Nas:listInput()
    return self:list({ [0] = self:getInput() })
end

function Nas:listOutput()
    return self:list({ [0] = self:getOutput() })
end

function Nas:iterateEmpty(inventories)
    local empties = self:listEmpty(inventories)

    return gen.create(function(yield, exec)
        arr.each(empties, function(set)
            local inv = set[1]
            local slot = set[2]
            yield(inv, slot)
        end)
    end)
end

function Nas:listEmpty(inventories)
    inventories = inventories or self:getStorage()

    local todo = {}
    local empties = {}

    for i, inv in pairs(inventories) do
        table.insert(todo, function()
            local list = inv.list()
            local size = inv.size()

            for slot = 1, size do
                if not list[slot] then
                    table.insert(empties, { inv, slot })
                end
            end
        end)
    end

    parallel.waitForAll(table.unpack(todo))

    return empties
end

function Nas:iterateEmptyInput()
    return self:iterateEmpty({ [0] = self:getInput() })
end

function Nas:iterateEmptyOutput()
    return self:iterateEmpty({ [0] = self:getOutput() })
end

return Nas
