local pp = require "cc.pretty".pretty_print
local arr = require("/scripts/api/arr")

local Search = require('/scripts/minedb/states/normal/search')
local List = require('/scripts/minedb/states/normal/list')
local Queue = require('/scripts/minedb/states/normal/queue')

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
        items = nil,
        ui = {},
    }

    return setmetatable(instance, state)
end

function state:init(states)
    -- Let's make this easier
    self.states = states

    local w, h = self.windows.comp.getSize()

    -- Create a window so we can set up the UI without rendering yet
    self.scene = window.create(self.windows.comp, 1, 1, w, h, false)

    -- Create subwindows
    self.searchSection = Search.new(self, self.scene)
    self.listSection = List.new(self, self.scene)
    self.queueSection = Queue.new(self, self.scene)

    -- Load the nas
    self:loadNas()

    return self
end

function state:loadNas()
    local items = arr.values(self.nas:list())

    table.sort(items, function(a, b)
        if a.getCount() == b.getCount() then
            return a.displayName() < b.displayName()
        end

        return a.getCount() >= b.getCount()
    end)

    self.items = items
end

function state:updateSearch()
    self.searchSection:update()
end

function state:updateList()
    self.listSection:update()
end

function state:updateQueue()
    self.queueSection:update()
end

function state:getSections()
    return {
        self.searchSection,
        self.listSection,
        self.queueSection
    }
end

function state:handleClick(name, button, x, y)
    local section = arr.find(self:getSections(), function(section)
        return section:hitTest(x, y)
    end)

    if section and section["handleClick"] then
        -- Calls a click handler with position localised to the subwindow
        local tx, ty = section.term.getPosition()
        return section:handleClick(x - (tx - 1), y - (ty - 1), x, y)
    end

    return false
end

function state:handleScroll(name, direction, x, y)
    local section = arr.find(self:getSections(), function(section)
        return section:hitTest(x, y)
    end)

    if section and section["handleScroll"] then
        -- Calls a click handler with position localised to the subwindow
        local tx, ty = section.term.getPosition()
        return section:handleScroll(direction, x - (tx - 1), y - (ty - 1), x, y)
    end

    return false
end

function state:handleKey(name, key, state)
    self.windows.toDebug(function()
        print(key)
    end)

    arr.each(self:getSections(), function(section)
        if section["handleKey"] then
            section:handleKey(key, state)
        end
    end)

    return false
end

function state:run()
    self.scene.setVisible(true)

    self:updateSearch()
    self:updateList()
    self:updateQueue()

    local nextScene

    repeat
        local continue = false
        nextScene = self.states.normal

        parallel.waitForAny(
            function()
                continue, nextScene = self:handleClick(os.pullEvent("mouse_click"))
            end,
            function()
                continue, nextScene = self:handleScroll(os.pullEvent("mouse_scroll"))
            end,
            function()
                local event, key = os.pullEvent("key")
                continue, nextScene = self:handleKey(event, key, true)
            end,
            function()
                local event, key = os.pullEvent("key_up")
                continue, nextScene = self:handleKey(event, key, false)
            end
        )
    until continue

    return nextScene or self.states.normal
end

return state
