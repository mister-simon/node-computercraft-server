local NAS = require("/scripts/minedb/nas-class")
local arr = require("/scripts/api/arr")
local ls = require("/scripts/api/localstorage")

-- Pulling
-- -- Run something like the "+stow" script.
-- -- If we run out of space, then throw out a big scary error.
-- -- Otherwise, throw back to normal mode.

local state = {}
state.__index = state

function state.new(nas)
    local instance = {
        nas = nas,
    }
    return setmetatable(instance, state)
end

function state:run(states)
    return states.normal
end

return state
