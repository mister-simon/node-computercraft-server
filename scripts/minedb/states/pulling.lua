local NAS = require("/scripts/minedb/nas-class")
local arr = require("/scripts/api/arr")
local ls = require("/scripts/api/localstorage")

-- Pulling
-- -- Run something like the "+stow" script.
-- -- If we run out of space, then throw out a big scary error.
-- -- Otherwise, throw back to normal mode.

local function createUiFor(output)
    local w, h = output.getSize()

    -- Create a window so we can set up the UI without rendering yet
    local scene = window.create(output, 1, 1, w, h, false)

    return {
        scene = scene
    }
end

--- @class PullingState
--- @field nas Nas
--- @field ui table
local state = {}
state.__index = state

--- @param nas Nas
function state.new(nas, windows)
    local preferredOutput = windows.comp

    if windows.mon then
        preferredOutput = windows.mon
    end

    local instance = {
        nas = nas,
        ui = createUiFor(preferredOutput),
    }
    return setmetatable(instance, state)
end

function state:run(states)
    return states.normal
end

return state
