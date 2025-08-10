local ensureWidth = require "cc.strings".ensure_width
local pp = require "cc.pretty".pretty_print
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

local function createBtn(text, x, y, bg, fg)
    bg = bg or colours.green
    fg = fg or colours.white

    local btn = Button.new()
    local w = text:len()
    btn:setText(text)
    btn:setSize(w, 1)
    btn:setBg(bg)
    btn:setFg(fg)
    btn:setPos(x, y)

    return btn
end

--- @class Normal2State
--- @field nas Nas
--- @field ui table
local state = {}
state.__index = state

--- @param nas Nas
function state.new(nas, windows)
    local instance = {
        nas = nas,
        windows = windows,
        ui = createUiFor(windows.comp),
        items = nil,
        search = nil,
        listOffset = 0,
        itemButtons = {}
    }

    return setmetatable(instance, state)
end

function state:loadNas()
    local items = arr.values(self.nas:list())

    table.sort(items, function(a, b)
        return a.getCount() >= b.getCount()
    end)

    self.items = items
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
        local indexW = 3
        local actionsW = 2
        local detailW = lw - indexW - actionsW

        self.itemButtons = {}

        term.clear()
        term.setCursorPos(1, 1)

        for i = 1, lh do
            local itemIndex = i + self.listOffset
            local collection = self.items[itemIndex]

            term.setCursorPos(1, i)

            term.setBackgroundColour(colours.black)
            term.setTextColour(colours.grey)

            if collection then
                write(ensureWidth(tostring(itemIndex), indexW))

                if (itemIndex % 2) == 0 then
                    term.setBackgroundColour(colours.grey)
                else
                    term.setBackgroundColour(colours.black)
                end

                term.setTextColour(colours.white)
                write(ensureWidth(" " .. collection.displayName(), detailW))

                local minus = createBtn("-", indexW + detailW, i)
                local plus = createBtn("+", indexW + detailW + 1, i)

                table.insert(self.itemButtons, { btn = minus, quantity = -1, collection = collection })
                table.insert(self.itemButtons, { btn = plus, quantity = 1, collection = collection })
            end

            term.setBackgroundColour(colours.black)
        end

        arr.each(self.itemButtons, function(item)
            item.btn:render()
        end)
    end);
end

function state:updateRight(states)
    toWindow(self.ui.right)(function()
        term.clear()
        term.setCursorPos(1, 1)

        print("Push Queue:")
        arr.each(states.pushing:getQueue(), function(job, i)
            pp(job)
        end)
    end)
end

function state:handleClick(states, name, button, x, y)
    local btn = arr.find(self.itemButtons, function(item)
        if item.btn:hitTest(x, y) then
            return true
        end
        return false
    end)

    if btn then
        states.pushing:queue({
            quantity = btn.quantity,
            name = btn.collection.name()
        })
        self:updateRight(states)
    end

    return false
end

function state:handleScroll(states, name, direction, x, y)
    local btn = arr.find(self.itemButtons, function(item)
        if item.btn:hitTest(x, y) then
            return true
        end
        return false
    end)

    if btn then
        states.pushing:queue({
            quantity = direction * -1,
            name = btn.collection.name()
        })
        self:updateRight(states)

        return false
    end

    self.listOffset = self.listOffset + direction
    self:updateLeft()
    self.ui.scene.redraw()

    return false
end

function state:handleTouch(states, name, side, direction, x, y)
    --
    return false
end

function state:run(states)
    self.windows.toBoth(function()
        term.clear()
        term.setCursorPos(1, 1)

        print("Loading...")
    end)

    self:loadNas()

    self.ui.scene.setVisible(true)

    self:updateTop()
    self:updateLeft(states)
    self:updateRight(states)

    self.ui.scene.redraw()

    local nextScene

    repeat
        local continue = false
        nextScene = states.normal

        parallel.waitForAny(function()
                continue, nextScene = self:handleClick(states, os.pullEvent("mouse_click"))
            end,
            function()
                continue, nextScene = self:handleScroll(states, os.pullEvent("mouse_scroll"))
            end,
            function()
                continue, nextScene = self:handleTouch(states, os.pullEvent("monitor_touch"))
            end
        )
    until continue ~= false

    return nextScene or states.normal
end

return state
