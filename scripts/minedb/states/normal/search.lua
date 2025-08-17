local toWindow   = require("/scripts/api/window").toWindow
local hitTest    = require("/scripts/api/window").hitTest
local arr        = require("/scripts/api/arr")
local completion = require("cc.completion")
local pp         = require "cc.pretty".pretty_print

local section    = {}
section.__index  = section

function section.new(parentState, scene)
    local w, h = scene.getSize()

    local instance = {
        parentState = parentState,
        parentWindow = scene,
        term = window.create(scene, 1, 1, w, 1),
        search = "*",
        hasFocus = false
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

function section:readInput()
    -- Creates autocompletes without mod namespaces
    local choices = arr.map(
        self.parentState.items,
        function(collection)
            return collection:name():match(":(.*)")
        end
    )

    toWindow(self.term)(function()
        term.clear()
        term.setCursorPos(1, 1)

        local default = nil

        if self.search ~= "*" then
            default = self.search
        end

        write("Search: ")
        local search = read(
            nil,
            nil,
            function(text)
                return completion.choice(text, choices)
            end,
            default
        )

        -- Default empty searches back to match all
        if search == "" then
            search = "*"
        end

        self.search = search

        self.hasFocus = false
    end)

    self:update()
    self.parentState:searchItems()

    self.parentState.listSection:resetOffset()
    self.parentState.listSection:update()
end

function section:handleClick(x, y, originalX, originalY)
    -- Setting hasFocus allows the parent scene to stop pulling events
    -- To allow input to be read
    self.hasFocus = true
end

function section:searchItems(items)
    if self.search == "*" then
        return items
    end


    local search = self.search

    -- Teehee
    if search:match("[.s|my|ur] mum$") ~= nil then
        search = "hoe"
    end

    return arr.filter(items, function(collection)
        return collection:name():find(search) ~= nil
    end)
end

return section
