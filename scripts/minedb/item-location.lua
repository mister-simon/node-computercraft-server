--- @class ItemLocation
local ItemLocation = {}
ItemLocation.__index = ItemLocation

function ItemLocation.new(inv, item, slot)
    local instance = {
        inv = inv,
        item = item,
        slot = slot,
    }

    return setmetatable(instance, ItemLocation)
end

function ItemLocation:getDetail()
    return self.inv.getItemDetail(self.slot)
end

function ItemLocation:getInvName()
    return peripheral.getName(self.inv)
end

function ItemLocation:pushTo(output, quantity, targetSlot)
    return self.inv.pushItems(
        peripheral.getName(output),
        self.slot,
        quantity,
        targetSlot
    )
end

function ItemLocation:getCount()
    local detail = self:getDetail()
    if not detail then
        return nil
    end
    return detail.count
end

function ItemLocation:getId()
    return self:getInvName() .. ":" .. self.slot
end

return ItemLocation
