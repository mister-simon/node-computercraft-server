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

local function pushToStorage(inv, targetSlot, input, slot, toMove)
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

local function compressInput(nas)
    print("-- Compressing Input --")

    local inputItems = nas:listInput()

    arr.each(inputItems, function(collection)
        term.clearLine()
        local x, y = term.getCursorPos()
        term.setCursorPos(1, y)
        write(collection.displayName())
        collection.compress()
    end)

    term.clearLine()
    local x, y = term.getCursorPos()
    term.setCursorPos(1, y)
    print("Done")
end

local function compressStorage(nas)
    print("-- Compressing Storage --")

    local items = nas:list()

    arr.each(items, function(collection)
        term.clearLine()
        local x, y = term.getCursorPos()
        term.setCursorPos(1, y)
        write(collection.displayName())
        collection.compress()
    end)

    print()
end

local function storeStuff(nas, input, failures, failuresWasIncremented)
    print("-- Storing Input --")

    local inputList = input.list()

    if arr.count(inputList) == 0 then
        print("Nothing to store :o")
        return failures, failuresWasIncremented
    end

    print("Getting fresh storage list...")
    local items = nas:list()

    print("Finding empty slots...")
    local emptyIterator = nas:iterateEmpty()

    print("Preparing moves...")
    local todo = {}

    for slot, item in pairs(inputList) do
        table.insert(todo, function()
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
                local emptyInv, emptySlot = emptyIterator()
                toMove = pushToStorage(emptyInv, emptySlot, input, slot, toMove)
            end

            if toMove ~= 0 and not failuresWasIncremented then
                print("!-- Failed to move: " .. displayName .. " " .. toMove .. " --!")
                failures = failures + 1
                failuresWasIncremented = true
            end
        end)
    end

    parallel.waitForAll(table.unpack(todo))

    return failures, failuresWasIncremented
end

local function stow(nas)
    local input = nas:getInput()
    local failures = 0

    repeat
        if failures ~= 0 then
            print("!== Retry attempts " .. failures .. " ==!")
        end

        -- Compress input
        compressInput(nas)

        -- Commenting this out for the moment...
        -- This should only be necessary if we're manually adding stuff to the storage:
        -- compressStorage(nas)

        -- Store the stuff
        local failuresWasIncremented = false
        failures, failuresWasIncremented = storeStuff(nas, input, failures, failuresWasIncremented)
    until arr.count(input.list()) == 0 or failures == 3

    if failures == 3 then
        print("Well damn - couldn't stow the input. Whatever it is. Chuck it in the bin.")
    end
end

return stow
