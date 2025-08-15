local function itemLocation(inv, item, slot)
    local function getDetail()
        return inv.getItemDetail(slot)
    end

    local function getInvName()
        return peripheral.getName(inv)
    end

    local function pushTo(output, quantity, targetSlot)
        return inv.pushItems(
            peripheral.getName(output),
            slot,
            quantity,
            targetSlot
        )
    end

    return {
        inv = inv,
        item = item,
        slot = slot,
        getDetail = getDetail,
        getInvName = getInvName,
        getCount = function()
            local detail = getDetail()
            if not detail then
                return nil
            end
            return detail.count
        end,
        getId = function()
            return getInvName() .. ":" .. slot
        end,
        pushTo = pushTo
    }
end

return itemLocation
