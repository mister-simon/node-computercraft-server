local toWindow = require("/scripts/api/window").toWindow
local hitTest = require("/scripts/api/window").hitTest

local section = {}
section.__index = section

function section.new(parentState, scene)
    local w, h = scene.getSize()

    local instance = {
        parentState = parentState,
        parentWindow = scene,
        term = window.create(scene, 1, 1, w, 1),
        search = "*"
    }
    instance._hitTest = hitTest(instance.term)

    return setmetatable(instance, section)
end

function section:update()
    toWindow(self.term)(function()
        term.clear()
        term.setCursorPos(1, 1)
        write("Search: " .. (self.search or "*"))
    end);
end

function section:hitTest(x, y)
    return self._hitTest(x, y)
end

function section:handleClick(x, y, originalX, originalY)
    toWindow(self.term)(function()
        term.clear()
        term.setCursorPos(1, 1)
        write(x .. ' ' .. y .. ' ' .. originalX .. ' ' .. originalY)
        sleep(3)
    end)
end

return section
