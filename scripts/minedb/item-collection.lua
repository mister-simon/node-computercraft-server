local arr = require("/scripts/api/arr")
local itemLocation = require("/scripts/minedb/item-location")
local compressCollection = require("/scripts/minedb/compress-collection")

-- Represents a single item type across a NAS
-- An item type is stored on the NAS in many locations
-- Each item location contains an inventory peripheral, item data, and slot number
local function itemCollection()
    local _locations = {}
    local _name
    local _displayName
    local _maxCount

    local function name(newName)
        if newName then
            _name = newName
        end
        return _name
    end

    local function displayName(newDisplayName)
        if newDisplayName then
            _displayName = newDisplayName
        end
        return _displayName
    end

    local function maxCount(newMaxCount)
        if newMaxCount then
            _maxCount = newMaxCount
        end
        return _maxCount
    end

    local function pushTo(out, quantity)
        repeat
            local failed = false
            arr.each(_locations, function(location)
                if quantity == 0 or failed then
                    return
                end

                local moved = location.pushTo(out, quantity)
                quantity = quantity - moved

                if moved == 0 then
                    failed = true
                end
            end)
        until quantity == 0 or failed

        return quantity
    end

    local exports = {
        name = name,
        displayName = displayName,
        maxCount = maxCount,
        getLocations = function()
            return _locations
        end,
        getCount = function()
            local count = 0
            arr.each(_locations, function(location)
                count = count + location.item.count
            end)
            return count
        end,
        addItem = function(inv, item, slot)
            local location = itemLocation(inv, item, slot)
            local detail = location.getDetail()

            if detail then
                -- Add the item
                table.insert(_locations, location)

                -- Update collection properties
                name(detail.name)
                displayName(detail.displayName)
                maxCount(detail.maxCount)
            end
        end,
        pushTo = pushTo
    }

    exports.compress = function()
        return compressCollection(exports)
    end

    return exports
end

return itemCollection
