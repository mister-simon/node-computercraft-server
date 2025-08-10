local say = require("/scripts/simnet/say")("left")

local dispenser = peripheral.wrap("top")

local function snowIsPlaced()
    return textutils.serialise(dispenser.list()):find("snow") == nil
end

local function snow()
    redstone.setOutput("top", true)
    sleep(0.5)
    redstone.setOutput("top", false)
end

local function collectSnow()
    if snowIsPlaced() then
        snow()
    end
end

local function placeSnow()
    if not snowIsPlaced() then
        snow()
    end
end

local function main()
    placeSnow()
    say("Stay frosty...")
    sleep(30)

    while turtle.attack() do
        turtle.drop()
    end

    say("Ice to meet you")
    collectSnow()

    sleep(40)

    return true
end

say("Shoulda strayed away!")
while main() do end
