local toWindow = require("/scripts/api/window").toWindow
local hitTest = require("/scripts/api/window").hitTest
local arr = require("/scripts/api/arr")

local section = {}
section.__index = section

function section.new(parentState, scene)
    local w, h = scene.getSize()

    local lw = math.floor((w / 3) * 2)
    local rw = w - lw

    local instance = {
        parentState = parentState,
        parentWindow = scene,
        term = window.create(scene, lw + 1, 2, rw, h - 1)
    }

    instance._hitTest = hitTest(instance.term)

    return setmetatable(instance, section)
end

function section:getQueue()
    return self.parentState.states.pushing:getQueue()
end

function section:update()
    toWindow(self.term)(function()
        term.clear()
        term.setCursorPos(1, 1)

        print("Push Queue:")
        arr.each(self:getQueue(), function(job, i)
            print(job.collection.getName() .. ':' .. job.quantity)
        end)
    end)
end

function section:hitTest(x, y)
    return self._hitTest(x, y)
end

function section:handleClick(x, y, originalX, originalY)
    toWindow(self.term)(function()
        term.clear()
        term.setCursorPos(1, 1)
        print(x, y, originalX, originalY)
        sleep(3)
    end)
end

return section
