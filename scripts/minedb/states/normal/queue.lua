local pp = require "cc.pretty".pretty_print
local ensureWidth = require "cc.strings".ensure_width
local toWindow = require("/scripts/api/window").toWindow
local hitTest = require("/scripts/api/window").hitTest
local arr = require("/scripts/api/arr")
local number = require("/scripts/api/number")
local Button = require("/scripts/api/button")

local section = {}
section.__index = section

function section.new(parentState, scene)
    local w, h = scene.getSize()

    local lw = math.floor((w / 3) * 2)
    local rw = w - lw

    local term = window.create(scene, lw + 1, 2, rw, h - 1)

    local instance = {
        parentState = parentState,
        parentWindow = scene,
        term = term,
        offset = 0,
        pushBtn = Button.make("Get", 1, h - 1, colours.green, colours.white, term),
        clearBtn = Button.make("Clear", rw - math.floor(rw / 2), h - 1, colours.grey, colours.lightGrey, term),
    }

    instance.pushBtn:setWidth(math.floor(rw / 2))
    instance.clearBtn:setWidth(rw - math.floor(rw / 2))

    instance._hitTest = hitTest(instance.term)

    return setmetatable(instance, section)
end

function section:getQueue()
    return self.parentState.states.pushing:getSortedQueue()
end

function section:update()
    toWindow(self.term)(function()
        local lw, lh = term.getSize()
        lh = lh - 1

        term.clear()
        term.setCursorPos(1, 1)

        local items = self:getQueue()

        for i = 1, lh do
            local itemIndex = i + self.offset
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

        self.pushBtn:render()
        self.clearBtn:render()
    end)
end

function section:hitTest(x, y)
    return self._hitTest(x, y)
end

function section:handleClick(x, y, originalX, originalY)
    if self.pushBtn:hitTest(x, y) then
        return true, self.parentState.states.pushing
    end

    if self.clearBtn:hitTest(x, y) then
        self.parentState.states.pushing:clearQueue()

        -- Cute lil animation... Why not.
        local w, h = self.term.getSize()
        local i = 1

        repeat
            self.term.scroll(-1 * i)
            self.pushBtn:render()
            self.clearBtn:render()
            i = i + i
            sleep(0.01)
        until i >= h

        self:update()
    end
end

function section:handleScroll(direction, x, y, originalX, originalY)
    -- Otherwise, assume the section needs scrolling
    local w, h = self.term.getSize()

    local prevOffset = self.offset

    self.offset = math.min(
        math.max(0, arr.count(self:getQueue()) - (h - 1)),
        math.max(0, self.offset + direction)
    )

    if self.offset ~= prevOffset then
        self:update()
    end
end

return section
