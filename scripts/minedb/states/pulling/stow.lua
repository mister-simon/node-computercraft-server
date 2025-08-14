local arr = require("/scripts/api/arr")

-- Get empty storage slots
local function pushToCollection(input, slot, toMove, max, collection)
    arr.each(
        collection.getLocations(),
        function(location)
            if toMove == 0 then
                return
            end

            if location.item.count == max then
                return
            end

            local moved = input.pushItems(
                location.getInvName(),
                slot,
                toMove,
                location.slot
            )

            toMove = toMove - moved
        end
    )

    return toMove
end

local function pushToStorage(emptyIterator, input, slot, toMove)
    local inv, targetSlot = emptyIterator()

    if not inv then
        return toMove
    end

    local moved = input.pushItems(
        peripheral.getName(inv),
        slot,
        toMove,
        targetSlot
    )

    toMove = toMove - moved

    return toMove, inv, targetSlot
end

local function stow(nas)
    local input = nas:getInput()
    local failures = 0

    repeat
        if failures ~= 0 then
            print("!== Retry attempts " .. failures .. " ==!")
        end

        -- Compress input
        local inputItems = nas:listInput()
        print("-- Compressing Input --")
        arr.each(inputItems, function(collection)
            term.clearLine()
            local x, y = term.getCursorPos()
            term.setCursorPos(1, y)
            write(collection.displayName())
            collection.compress()
        end)
        print()

        -- Compress all
        local items = nas:list()

        print("-- Compressing Storage --")
        arr.each(items, function(collection)
            term.clearLine()
            local x, y = term.getCursorPos()
            term.setCursorPos(1, y)
            write(collection.displayName())
            collection.compress()
        end)
        print()

        -- Get a new list ready to work with
        local items = nas:list()
        local inputList = input.list()

        local emptyIterator = nas:listEmpty()

        local failuresWasIncremented = false

        print("-- Storing Input --")

        for slot, item in pairs(input.list()) do
            local collection = items[item.name]
            local toMove = item.count

            local detail = input.getItemDetail(slot)
            local displayName = detail.displayName
            local max = detail.maxCount

            if collection ~= nil then
                print("Adding to collection " .. displayName)
                toMove = pushToCollection(input, slot, toMove, max, collection)
            end

            if toMove ~= 0 then
                print("Pushing the rest to empty space " .. displayName .. " " .. toMove)
                toMove = pushToStorage(emptyIterator, input, slot, toMove)
            end

            if toMove ~= 0 and not failuresWasIncremented then
                print("!-- Failed to move: " .. displayName .. " " .. toMove .. " --!")
                failures = failures + 1
                failuresWasIncremented = true
            end
        end
        term.scroll(2)
    until arr.count(inputList) == 0 or failures == 3

    if failures == 3 then
        print("Well damn - couldn't stow the input. Whatever it is. Chuck it in the bin.")
    end
end

return stow
