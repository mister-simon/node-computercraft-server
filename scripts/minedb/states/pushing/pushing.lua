local toWindow = require("/scripts/api/window").toWindow
local ensureWidth = require "cc.strings".ensure_width
local arr = require("/scripts/api/arr")
local number = require("/scripts/api/number")
local Button = require("/scripts/api/button")

-- Pushing
-- -- Consume the internal queue until there is no space left to output into.
-- -- If the queue fails then prompt the user to continue or cancel.
-- -- When done or cancelled, throw back to normal state.

--- @class PushingState
local state = {}
state.__index = state

--- @param nas Nas
function state.new(nas, windows)
    local instance = {
        nas = nas,
        windows = windows,
        _queue = {},
    }

    return setmetatable(instance, state)
end

function state:init(states)
    self.states = states

    local w, h = self.windows.comp.getSize()

    -- Create a window so we can set up the UI without rendering yet
    self.scene = window.create(self.windows.comp, 1, 1, w, h, false)

    local lw = math.floor((w / 3) * 2)
    local rw = w - lw

    self.listSection = window.create(self.scene, 1, 1, lw, h - 1)
    self.failedSection = window.create(self.scene, lw + 1, 1, rw, h - 1)
    self.actionSection = window.create(self.scene, 1, h, w, 1)

    self.cancelBtn = Button.make("Cancel", 1, 1, colours.red, colours.white, self.actionSection)

    return self
end

function state:clearQueue()
    self._queue = {}
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

function state:list()
    toWindow(self.listSection)(function()
        local lw, lh = term.getSize()

        -- term.clear()
        -- term.setCursorPos(1, 1)

        local items = arr.values(self:getQueue())

        table.sort(items, function(a, b)
            return a.collection.displayName() < b.collection.displayName()
        end)

        for i = 1, lh do
            local itemIndex = i
            local job = items[itemIndex]

            term.setCursorPos(1, i)

            term.setBackgroundColour(colours.black)
            term.setTextColour(colours.grey)

            if job then
                if (itemIndex % 2) == 0 then
                    term.setBackgroundColour(colours.grey)
                else
                    term.setBackgroundColour(colours.black)
                end

                term.setTextColour(colours.white)

                write(ensureWidth(number.toShortString(job.quantity), 4))
                write(ensureWidth(" " .. job.collection.displayName(), lw - 4))
            end

            term.setBackgroundColour(colours.black)
        end
    end)
end

function state:run()
    self.scene.setVisible(true)
    toWindow(self.scene)(function()
        term.clear()

        self.listSection.setBackgroundColour(colours.green)
        self.listSection.clear()

        self.failedSection.setBackgroundColour(colours.blue)
        self.failedSection.clear()

        self.actionSection.setBackgroundColour(colours.orange)
        self.actionSection.clear()
    end)

    self:list()

    sleep(3)

    return self.states.normal
end

return state
