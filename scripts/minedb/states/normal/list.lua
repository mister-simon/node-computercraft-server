local ensureWidth = require "cc.strings".ensure_width
local toWindow = require("/scripts/api/window").toWindow
local hitTest = require("/scripts/api/window").hitTest
local number = require("/scripts/api/number")
local arr = require("/scripts/api/arr")
local Button = require("/scripts/api/button")

local section = {}
section.__index = section

function section.new(parentState, scene)
    local w, h = scene.getSize()

    local lw = math.floor((w / 3) * 2)

    local term = window.create(scene, 1, 2, lw, h - 1)

    local instance = {
        parentState = parentState,
        parentWindow = scene,
        term = term,
        queueStack = false,
        queueAll = false,
        offset = 0,
        buttons = {},
        pullBtn = Button.make("Stow Input", 1, h - 1, colours.green, colours.white, term),
        refreshBtn = Button.make("Refresh", 1, h - 1, colours.grey, colours.lightGrey, term),
        refreshing = false,
    }
    instance._hitTest = hitTest(instance.term)

    instance.pullBtn:setWidth(instance.pullBtn.w + 2)

    instance.refreshBtn:setWidth(instance.refreshBtn.w + 2)
    instance.refreshBtn:setX(lw - instance.refreshBtn.w)

    return setmetatable(instance, section)
end

function section:update()
    local function renderList(withButtons)
        local lw, lh = term.getSize()
        lh = lh - 1

        local indexW = 0
        local actionsW = 2
        local detailW = lw - indexW

        if withButtons then
            detailW = detailW - actionsW
        end

        term.clear()
        term.setCursorPos(1, 1)

        for i = 1, lh do
            local itemIndex = i + self.offset
            local collection = self.parentState.searchedItems[itemIndex]

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
                write(ensureWidth(number.toShortString(collection.getCount()), 4))
                write(ensureWidth(" " .. collection.displayName(), detailW - 4))

                if withButtons or false then
                    local minus = Button.make("-", indexW + detailW, i)
                    local plus = Button.make("+", indexW + detailW + 1, i)

                    table.insert(self.buttons, { btn = minus, quantity = -1, collection = collection })
                    table.insert(self.buttons, { btn = plus, quantity = 1, collection = collection })
                end
            end

            term.setBackgroundColour(colours.black)
        end

        if withButtons or false then
            self.pullBtn:render()
            self.refreshBtn:render()
        end
    end

    self.buttons = {}

    -- Render the whole list to the list area
    toWindow(self.term)(function()
        renderList(true)
        arr.each(self.buttons, function(item)
            item.btn:render()
        end)
    end);

    -- Render the list again for a connected monitor, no buttons
    self.parentState.windows.toMon(function()
        renderList(false)
    end);
end

function section:refresh()
    toWindow(self.term)(function()
        -- Cute lil animation... Why not.
        local w, h = term.getSize()
        local i = 1

        repeat
            term.scroll(-1)

            term.setCursorPos(math.floor(w / 2) - 5, 1)
            term.write('Loading...')

            i = i + 1
            sleep(0.01)
        until i > h
    end)
end

function section:resetOffset()
    self.offset = 0
end

function section:hitTest(x, y)
    return self._hitTest(x, y)
end

function section:hitTestButtons(x, y)
    return arr.find(self.buttons, function(item)
        return item.btn:hitTest(x, y)
    end)
end

function section:getQueueQuantity(quantity, collection)
    if self.queueAll then
        return quantity * collection.getCount()
    end

    if self.queueStack then
        return quantity * collection.maxCount()
    end

    return quantity
end

function section:handleClick(x, y, originalX, originalY)
    local btn = self:hitTestButtons(x, y)

    local pushState = self.parentState.states.pushing

    if btn then
        pushState:queue({
            quantity = self:getQueueQuantity(btn.quantity, btn.collection),
            collection = btn.collection
        })
        self.parentState.queueSection:update()

        return false
    end

    if self.pullBtn:hitTest(x, y) then
        return true, self.parentState.states.pulling
    end

    if self.refreshBtn:hitTest(x, y) then
        self.refreshing = true

        return true
    end

    return false
end

function section:handleScroll(direction, x, y, originalX, originalY)
    local btn = self:hitTestButtons(x, y)

    -- If -/+ buttons were scrolled queue with direction
    local pushState = self.parentState.states.pushing
    if btn then
        pushState:queue({
            quantity = self:getQueueQuantity(direction * -1, btn.collection),
            collection = btn.collection
        })
        self.parentState.queueSection:update()

        return false
    end

    -- Otherwise, assume the section needs scrolling
    local w, h = self.term.getSize()

    local prevOffset = self.offset

    self.offset = math.min(
        math.max(0, arr.count(self.parentState.searchedItems) - h),
        math.max(0, self.offset + direction)
    )

    if self.offset ~= prevOffset then
        self:update()
    end
end

function section:handleKey(key, state)
    local name = keys.getName(key)

    if not name then
        return false
    end

    if name == "leftCtrl" then
        self.queueAll = state

        return false
    end

    if name == "leftShift" then
        self.queueStack = state

        return false
    end
end

return section
