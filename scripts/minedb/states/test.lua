local pp = require "cc.pretty".pretty_print
local arr = require("/scripts/api/arr")
local toWindow = require("/scripts/api/window").toWindow
local number = require("/scripts/api/number")

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
    -- Let's make this easier
    self.states = states

    local w, h = self.windows.comp.getSize()

    -- Create a window so we can set up the UI without rendering yet
    self.scene = window.create(self.windows.comp, 1, 1, w, h, false)

    return self
end

-- This is a test scene to easily try stuff without having to mess
-- with the main states / scenes.
function state:run()
    self.scene.setVisible(true)

    -- toWindow(self.scene)(function()
    --     print("Loading...")

    --     local list = self.nas:list()
    --     local first = arr.find(list, function()
    --         return true
    --     end)

    --     local quantity = first.getCount()
    --     local out = self.nas:getOutput()


    --     print(first.displayName(), quantity)

    --     local remaining = first.pushTo(out, quantity)

    --     print("Moved " .. (quantity - remaining))

    --     read()
    -- end)

    return self.states.normal
end

return state
