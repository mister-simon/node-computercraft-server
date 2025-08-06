local say = require("/scripts/simnet/say")

local function snow()
    redstone.setOutput("top", true)
    sleep(0.5)
    redstone.setOutput("top", false)
end

local function main()
    snow()
    sleep(30)
    snow()

    while turtle.attack() do end

    sleep(40)

    return true
end

say("Shoulda strayed away!")
while main() do end
