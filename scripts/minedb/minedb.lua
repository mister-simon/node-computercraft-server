local pp = require("cc.pretty").pretty_print

local arr = require("/scripts/api/arr")
local startup = require("/scripts/minedb/states/startup/startup")
local test = require("/scripts/minedb/states/test")
local normal = require("/scripts/minedb/states/normal/normal")
local pulling = require("/scripts/minedb/states/pulling/pulling")
local pushing = require("/scripts/minedb/states/pushing/pushing")

local function main()
    local compWindow = term.current()

    -- Startup
    local nas, windows = startup(compWindow)

    local states = {
        test = test.new(nas, windows),
        normal = normal.new(nas, windows),
        pulling = pulling.new(nas, windows),
        pushing = pushing.new(nas, windows),
    }

    parallel.waitForAll(function()
        states.test:init(states)
    end, function()
        states.normal:init(states)
    end, function()
        states.pulling:init(states)
    end, function()
        states.pushing:init(states)
    end)

    -- Init done. Clear the startup screen and begin.
    windows.toBoth(function()
        term.clear()
        term.setCursorPos(1, 1)
    end)

    -- Run those states
    local state = states.test

    repeat
        state = state:run()
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
