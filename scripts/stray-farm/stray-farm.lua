local say = require("/scripts/simnet/say")

local function snow()
    redstone.setOutput("top", true)
    redstone.setOutput("top", false)
    sleep(1)
    redstone.setOutput("top", true)
    redstone.setOutput("top", false)
end

local function main()
    sleep(30)

    snow()

    sleep(30)

    while turtle.attack() do end

    return true
end

say("Shoulda strayed away!")
while main() do end
