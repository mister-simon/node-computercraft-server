local pretty = require("cc.pretty")
local localstorage = require("/scripts/api/localstorage")

local inputChest = localstorage.get("minedb", "input", nil)
local outputChest = localstorage.get("minedb", "output", nil)

local args = { ... }
local search = args[1]
local amount = tonumber(args[2] or 64)

function getStorage()
    return peripheral.find(
        "inventory",
        function(name, inv)
            if name == inputChest then return false end
            if name == outputChest then return false end
            return true
        end
    )
end

function getEmptyStorage()

end

local function find(search, findAll)
    findAll = findAll or false

    local invs = { getStorage() }
    local matches = {}

    for i = 1, #invs do
        local inv = invs[i]

        for slot, item in pairs(inv.list()) do
            if item.name:find(search) ~= nil then
                local match = { inv = inv, slot = slot, item = item }

                if findAll then
                    table.insert(matches, match)
                else
                    return match
                end
            end
        end
    end

    return matches
end


if not search then
    print("Provide a search argument")
    return
end

if not inputChest then
    print("Use localstorage to set minedb.input to input chest name on network")
end

if not outputChest then
    print("Use localstorage to set minedb.output to output chest name on network")
end

local outInv = peripheral.wrap(outputChest)
local matches = find(search, true)
local outputCount = 0

for i = 1, #matches do
    local match = matches[i]

    if outputCount == amount then
        break
    end

    local transferred = outInv.pullItems(
        peripheral.getName(match.inv),
        match.slot,
        amount
    )
    outputCount = outputCount + transferred
end

print(("Outputted %d '%s'"):format(outputCount, search))
