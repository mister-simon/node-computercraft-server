local go = require("/scripts/api/go")
local inv = require("/scripts/api/inv")

local refuelAt = 100
local instantLeafDecay = false

local quietMode = false

--------------------------------
-- Side view of treefarm setup:
-- TT - Turtle
-- DD - Dirt
-- DC - Dump Chest (drop sticks, logs, etc)
-- CC - Composter
-- </ - Hopper pointing < that way
-- BR - Bone Retrieval
-- (Water flow centred on CC)

-- -- -- -- -- -- -- -- -- DC --
-- -- -- -- -- TT -- -- -- -- CC
-- -- -- -- DD -- -- -- -- BR </
-- -- -- -- -- -- -- -- -- -- --
-- == >> >> >> >> << << << << ==
--------------------------------

local function say(msg)
    if quietMode then return end
    print()
    print(msg)
end

local function slowSay(msg, durationInSeconds)
    if quietMode then return end

    print()
    textutils.slowPrint(msg, #msg / durationInSeconds)
end


local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    say("I have " .. fuelLevel .. " fuel left.")

    if fuelLevel > refuelAt then
        say("That's actually fine.")
        return true
    end

    say("Sticks and logs may fuel my cogs!")
    if inv.selectItem("stick", true) or inv.selectItem("log", true) then
        return turtle.refuel()
    end

    -- Something went wrong / no fuel to be found
    return false
end

local function storeStuff()
    while inv.selectItem('log', true) or inv.selectItem('stick') do
        say("Droppin a " .. turtle.getItemDetail()["name"])

        if not turtle.dropUp() then
            say("This chest ful... Seeya")
            return false
        end
    end

    return true
end

local function compostExcess()
    -- Compost em
    local saplingStacks = findItems('sapling', true)

    -- Keep one stack, compost excess
    if #saplingStacks > 1 then
        say("I got saps here:" .. textutils.serialise(saplingStacks))

        for i = #saplingStacks, 2, -1 do
            turtle.select(saplingStacks[i])

            while turtle.getItemCount() ~= 0 do
                turtle.place()
            end

            say("Moving on...")
        end
    end
end

local function getBoned()
    -- Put away all the bonemeal
    local boneStacks = findItems('bone_meal', true)

    if #boneStacks == 0 and not turtle.suckDown() then
        say("No bones today...")
        return false
    end

    boneStacks = findItems('bone_meal', true)

    for i = 1, #boneStacks do
        turtle.select(boneStacks[i])
        turtle.dropDown()
        say("Pop this away.")
    end

    -- Try to refill the stack
    while turtle.getItemSpace() ~= 0 and turtle.suckDown(turtle.getItemSpace()) do end
end

local function dump()
    say("Its 2:00 - >_>")

    go.turnAround()
    go.forward(4)

    storeStuff()
    compostExcess()
    getBoned()

    say("Break's over.")

    go.turnAround()
    go.forward(4)

    return true
end

local function selectSaplings()
    say("Have sapling?")
    return inv.selectItem('sapling', true)
end

local function selectBonemeal()
    say("Have bone?")
    return inv.selectItem('bone_meal', true)
end

local function plantSapling()
    if not selectSaplings() then
        say("Uhoh! No sappers")
        return false
    end

    say("Activating green fingers~")
    return turtle.place()
end

local function waitForGrowth()
    say("Waiting for tree...")

    repeat
        say("Zzzz...")

        os.sleep(5)
        local isBlock, blockData = turtle.inspect()

        if not isBlock then
            return false
        end

        local isLog = blockData["name"]:find('log') ~= nil
    until isLog

    say("It grew!")

    return true
end

local function growTree()
    say("Grow grow grow!")

    repeat
        if not (selectBonemeal() and turtle.place()) then
            return waitForGrowth()
        end

        local isBlock, blockData = turtle.inspect()
        local isLog = blockData["name"]:find('log') ~= nil

        if not isBlock then
            return false
        end

        if not isLog then
            say("Please grow!?")
        end
    until isLog

    say("It grew!")

    return true
end

local function mineTree()
    say("Get to de choppah")
    local uppies = 0

    go.forward()
    while turtle.detectUp() do
        go.up(1, function() uppies = uppies + 1 end)
    end
    go.down(uppies)
    go.back()

    return true
end

local function waitForLeafDecay()
    say("Decay...")
    local waitMsg, waitSecs

    if instantLeafDecay then
        waitMsg = "Entropy is life"
        waitSecs = 4
    else
        waitMsg = "Autumn is over the long leaves that love us,"
        waitSecs = 60
    end

    slowSay(waitMsg, waitSecs)
end

local function collectSaplings()
    say("Let's get sappy")

    -- Select the first sapling stack to refill it
    inv.selectItem('sapling', true)

    while turtle.suck() do
        say("There was something on this dirt block. Cool.")
        os.sleep(1)
    end

    while turtle.suckUp() do
        say("Something on me head LOL.")
        os.sleep(1)
    end

    go.down()

    while turtle.suckDown() do
        say("Got something. Maybe there's more")
        os.sleep(1)
    end

    go.up()

    return true
end

local function main()
    -- Refuel
    if not refuel() then
        say("I ran out of energ... Pls, insert log or stick... Zzzz.")
        return false
    end

    if not dump() then
        say("I had an accident?")
        return false
    end

    -- Plant sapling
    if not plantSapling() then
        say("Oh, I forgot; I don't have fingers.")
        return false
    end

    -- Prep bonemeal
    if not growTree() then
        say("That tree ain't growing, my friend... I give up.")
        return false
    end

    -- Mine tree
    if not mineTree() then
        say("This tree got confusing. Not my problem now matei.")
        return false
    end

    -- Wait for saplings
    waitForLeafDecay()

    -- Collect saplings
    -- Compost excess saplings
    if not collectSaplings() then
        say('Saplings are dumb anyway')
        return false
    end

    return true
end

-- Get it goin
-- main()
while main() do end
