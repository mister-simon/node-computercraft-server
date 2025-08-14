local toWindow = require("/scripts/api/window").toWindow
local ensureWidth = require "cc.strings".ensure_width
local arr = require("/scripts/api/arr")
local number = require("/scripts/api/number")
local Button = require("/scripts/api/button")
local stow = require("/scripts/minedb/states/pulling/stow")

-- Pulling
-- -- Run something like the "+stow" script.
-- -- If we run out of space, then throw out a big scary error.
-- -- Otherwise, throw back to normal mode.

--- @class PullingState
--- @field nas Nas
--- @field ui table
local state = {}
state.__index = state

--- @param nas Nas
function state.new(nas, windows)
    local instance = {
        nas = nas,
        windows = windows,
    }
    return setmetatable(instance, state)
end

function state:init(states)
    self.states = states

    local w, h = self.windows.comp.getSize()

    -- Create a window so we can set up the UI without rendering yet
    self.scene = window.create(self.windows.comp, 1, 1, w, h, false)

    return self
end

function state:run()
    self.scene.setVisible(true)
    toWindow(self.scene)(function()
        term.clear()
        parallel.waitForAll(function()
            stow(self.nas)
        end)
    end)

    return self.states.normal
end

return state
