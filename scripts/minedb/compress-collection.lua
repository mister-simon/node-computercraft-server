local function compressCollection(collection)
    local locations = collection.getLocations()
    local max = collection.maxCount()

    local function move(current, target, amount)
        if current.getId() == target.getId() then
            return 0
        end

        if target.getCount() == max then
            return 0
        end

        print(current.getId() .. " <> " .. target.getId())

        return current.inv.pushItems(
            target.getInvName(),
            current.slot,
            amount,
            target.slot
        )
    end

    local function compressLocation(location, index, max)
        local count = location.getCount()

        if not count or count == max then
            return
        end

        local toMove = count

        for target = index, #locations do
            if toMove == 0 then
                return
            end

            local moved = move(location, locations[target], toMove)
            toMove = toMove - moved
        end
    end

    for current = 1, #locations do
        compressLocation(locations[current], current, max)
    end
end

return compressCollection
