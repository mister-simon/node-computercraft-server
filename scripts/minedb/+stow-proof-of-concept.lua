local pp     = require("cc.pretty").pretty_print
local getNas = require("/scripts/minedb/nas")
local arr    = require("/scripts/api/arr")

local nas    = getNas("back")
nas.setInputName('minecraft:chest_17')
nas.setOutputName('minecraft:chest_16')

local items = nas.list()
local input = nas.getInput()

for slot, item in pairs(input.list()) do
    local collection = items[item.name]
    local toMove = item.count

    local detail = input.getItemDetail(slot)
    local displayName = detail.displayName
    local max = detail.maxCount

    print(displayName)

    if collection ~= nil then
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
    else
        print("We don't have " .. item.name)
    end
end