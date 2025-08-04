local pp = require("cc.pretty").pretty_print
local ls = require("/scripts/api/localstorage")
local arr = require("/scripts/api/arr")
local NAS = require("/scripts/minedb/nas-class")

local startup = require("/scripts/minedb/states/startup")
local normal = require("/scripts/minedb/states/normal")
local pulling = require("/scripts/minedb/states/pulling")
local pushing = require("/scripts/minedb/states/pushing")

local function main()
    -- Startup
    local nas = startup()

    local states = {
        normal = normal.new(nas),
        pulling = pulling.new(nas),
        pushing = pushing.new(nas),
    }

    local state = states.normal

    -- Run those states
    repeat
        state = state.run(states)
    until not state

    term.setBackgroundColour(colours.black)
    term.clear()
    term.setCursorPos(1, 1)
end

main()
