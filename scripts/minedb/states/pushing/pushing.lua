-- Pushing
-- -- Consume the internal queue until there is no space left to output into.
-- -- If the queue fails then prompt the user to continue or cancel.
-- -- When done or cancelled, throw back to normal state.

local function createUiFor(output)
    local w, h = output.getSize()

    -- Create a window so we can set up the UI without rendering yet
    local scene = window.create(output, 1, 1, w, h, false)

    return {
        scene = scene
    }
end

--- @class PushingState
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
        _queue = {},
    }

    return setmetatable(instance, state)
end

function state:init(states)
    self.states = states
    return self
end

function state:queue(item)
    local collection = item.collection
    local name = collection.name()

    if not self._queue[name] then
        self._queue[name] = {
            collection = collection,
            quantity = 0
        }
    end

    local current = self._queue[name].quantity

    self._queue[name].quantity = math.min(
        math.max(0, current + item.quantity),
        collection.getCount()
    )

    if self._queue[name].quantity == 0 then
        self._queue[name] = nil
    end
end

function state:getQueue()
    return self._queue
end

function state:run(states)
    return self.states.normal
end

return state
