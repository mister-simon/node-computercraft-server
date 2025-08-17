local arr = require("/scripts/api/arr")
local ItemLocation = require("/scripts/minedb/item-location")
local compressCollection = require("/scripts/minedb/compress-collection")

-- Represents a single item type across a NAS
-- An item type is stored on the NAS in many locations
-- Each item location contains an inventory peripheral, item data, and slot number

--- @class ItemCollection
local ItemCollection = {}
ItemCollection.__index = ItemCollection

function ItemCollection.new()
    local instance = {
        _locations = {},
        _details = false
    }

    return setmetatable(instance, ItemCollection)
end

function ItemCollection:locations()
    return self._locations
end

function ItemCollection:name()
    return self._details.name
end

function ItemCollection:displayName()
    return self._details.displayName
end

function ItemCollection:maxCount()
    return self._details.maxCount
end

function ItemCollection:pushTo(out, quantity)
    repeat
        local failed = false

        arr.each(self._locations, function(location)
            if quantity == 0 or failed then
                return
            end

            local moved = location:pushTo(out, quantity)
            quantity = quantity - moved

            if moved == 0 then
                failed = true
            end
        end)
    until quantity == 0 or failed

    return quantity
end

function ItemCollection:getCount()
    local count = 0
    arr.each(self._locations, function(location)
        count = count + location.item.count
    end)
    return count
end

function ItemCollection:addItem(inv, item, slot)
    local location = ItemLocation.new(inv, item, slot)

    if not self._details then
        self._details = location:getDetail()
    end

    -- Add the item
    table.insert(self._locations, location)
end

function ItemCollection:compress()
    return compressCollection(self)
end

return ItemCollection
