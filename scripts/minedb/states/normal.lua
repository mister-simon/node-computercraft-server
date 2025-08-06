local ensureWidth = require "cc.strings".ensure_width
local arr = require("/scripts/api/arr")
local Button = require("/scripts/api/button")
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

local function createBtn(text, action, bg, fg)
    bg = bg or colours.green
    fg = fg or colours.white

    local btn = Button.new()
    local w = text:len()
    btn:setText(text)
    btn:setSize(w, 1)
    btn:setBg(bg)
    btn:setFg(fg)

    return {
        btn = btn,
        action = action,
        w = w
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
        usingMonitor = preferredOutput ~= windows.comp,
        items = nil,
        search = nil,
        listOffset = 0,
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

function state:updateLeft(states)
    toWindow(self.ui.left)(function()
        local lw, lh = term.getSize()
        local indexW = 4
        local actionsW = 11
        local detailW = lw - indexW - actionsW

        term.clear()
        term.setCursorPos(1, 1)

        print("Loading...")

        local items = arr.values(self.nas:list())

        table.sort(items, function(a, b)
            return a.getCount() >= b.getCount()
        end)

        term.clear()
        term.setCursorPos(1, 1)

        self.leftBtns = {}

        for i = 1, lh do
            local itemIndex = i + self.listOffset
            local collection = items[itemIndex]

            term.setCursorPos(1, i)

            if (i % 2) == 0 then
                term.setBackgroundColour(colours.grey)
            else
                term.setBackgroundColour(colours.black)
            end

            if collection then
                write(ensureWidth(i .. "-", indexW))
                write(ensureWidth(collection.displayName(), detailW))

                local one = createBtn("1", function()
                    states.pushing:queue({
                        quantity = 1,
                        name = collection.name()
                    })
                    self:updateRight()
                    self.ui.scene.redraw()

                    return true
                end)

                one.btn:setPos(indexW + detailW, i)

                local stack = createBtn("64", function()
                    states.pushing:queue({
                        quantity = 64,
                        name = collection.name()
                    })
                    self:updateRight()
                    self.ui.scene.redraw()

                    return true
                end)
                stack.btn:setPos(indexW + detailW + 2, i)

                local all = createBtn("ALL", function()
                    states.pushing:queue({
                        quantity = collection.getCount(),
                        name = collection.name()
                    })
                    self:updateRight()
                    self.ui.scene.redraw()

                    return true
                end)
                all.btn:setPos(indexW + detailW + 3, i)

                self.leftBtns = {
                    one, stack, all
                }

                one.btn:render()
                stack.btn:render()
                all.btn:render()
            end
        end
    end);
end

function state:updateRight(states)
    toWindow(self.ui.right)(function()
        term.clear()
        term.setCursorPos(1, 1)

        arr.each(states.pushing:getQueue(), function(job, i)
            print(i)
        end)
    end)
end

function state:run(states)
    self.ui.scene.setVisible(true)

    self:updateTop()
    self:updateLeft(states)
    self:updateRight(states)

    self.ui.scene.redraw()

    repeat
        local continue = true

        parallel.waitForAny(
            table.unpack(arr.map(self.leftBtns, function(item)
                return function()
                    local btn = item["btn"]
                    local action = item["action"]

                    btn:listen(self.usingMonitor)
                    self.ui.left.write("Hello")

                    continue = action()
                end
            end))
        )
    until not continue

    return states.normal
end

return state
