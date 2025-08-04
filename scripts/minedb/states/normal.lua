local arr = require("/scripts/api/arr")
local toWindow = require("/scripts/api/window").toWindow

-- Normal
-- -- Top: Search / filter
-- -- -- Search bar

-- -- Left: Items
-- -- -- Top: List
-- -- -- -- Item
-- -- -- -- Quantity
-- -- -- -- Actions
-- -- -- -- -- 1, 16, 64, All
-- -- -- Bottom: [Pull] toggle

-- -- Right: Queue
-- -- -- Top: List
-- -- -- Bottom: [Push] Queue

local function createUiFor(output)
    local w, h = output.getSize()

    -- Create a window so we can set up the UI without rendering yet
    local scene = window.create(output, 1, 1, w, h, false)

    -- Create subwindows to manage sections of UI
    local top = window.create(scene, 1, 1, w, 1)

    local lw = math.floor((w / 3) * 2)
    local left = window.create(scene, 1, 2, lw, h - 1)

    local rw = w - lw
    local right = window.create(scene, lw + 1, 2, rw, h - 1)

    return {
        scene = scene,
        top = top,
        left = left,
        right = right,
    }
end


--- @class NormalState
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
        items = nil,
        search = nil,
    }

    return setmetatable(instance, state)
end

function state:updateTop()
    toWindow(self.ui.top)(function()
        term.clear()
        term.setCursorPos(1, 1)
        write("Search: " .. (self.search or "*"))
    end);
end

function state:updateLeft()
    toWindow(self.ui.left)(function()
        print("Loading...")

        local items = self.nas:list()

        term.clear()
        term.setCursorPos(1, 1)

        arr.each(items, function(collection, name)
            print(collection.displayName() .. " x" .. collection.getCount())
        end)
    end);
end

function state:updateRight()
end

function state:run(states)
    self.ui.scene.setVisible(true)

    self:updateTop()
    self:updateLeft()
    self:updateRight()

    self.ui.scene.redraw()
    sleep(3)

    -- return states.pulling
end

return state
