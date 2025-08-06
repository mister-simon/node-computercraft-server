local pp = require("cc.pretty").pretty_print

local startup = require("/scripts/minedb/states/startup")
local normal = require("/scripts/minedb/states/normal")
local pulling = require("/scripts/minedb/states/pulling")
local pushing = require("/scripts/minedb/states/pushing")

local function main()
    local compWindow = term.current()

    -- Startup
    local nas, windows = startup(compWindow)

    local states = {
        normal = normal.new(nas, windows),
        pulling = pulling.new(nas, windows),
        pushing = pushing.new(nas, windows),
    }

    local state = states.normal

    -- Run those states
    repeat
        state = state:run(states)
    until not state

    windows.toBoth(function()
        term.setBackgroundColour(colours.black)
        term.clear()
        term.setCursorPos(1, 1)

        print("Bye! :)")
        sleep(1)

        term.clear()
        term.setCursorPos(1, 1)
    end)
end

main()
