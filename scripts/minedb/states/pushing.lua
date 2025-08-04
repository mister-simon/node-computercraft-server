local NAS = require("/scripts/minedb/nas-class")
local arr = require("/scripts/api/arr")
local ls = require("/scripts/api/localstorage")

-- Pushing
-- -- Consume the internal queue until there is no space left to output into.
-- -- If the queue fails then prompt the user to continue or cancel.
-- -- When done or cancelled, throw back to normal state.

local state = {}
state.__index = state

function state.new(nas)
    local instance = {
        nas = nas,
        _queue = {},
    }

    return setmetatable(instance, state)
end

function state:queue(...)
    table.insert(self._queue, { ... })
end

function state:run(states)
    return states.normal
end

return state
