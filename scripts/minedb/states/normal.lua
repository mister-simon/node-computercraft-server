local NAS = require("/scripts/minedb/nas-class")
local arr = require("/scripts/api/arr")
local ls = require("/scripts/api/localstorage")

-- Normal
-- -- Top: Search / filter
-- -- -- Search bar

-- -- Left: Items
-- -- -- Top: List
-- -- -- -- Item
-- -- -- -- Quantity
-- -- -- -- Actions
-- -- -- -- -- 1, 16, 64, All
-- -- -- Bottom: Pull input toggle

-- -- Right: Queue
-- -- -- Top: List
-- -- -- Bottom: Push queue

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
