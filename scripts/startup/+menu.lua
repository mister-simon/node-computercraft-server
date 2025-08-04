-- Example of a startup menu system using buttons
local Button = require("/scripts/api/button")
local arr = require("/scripts/api/arr")

local w = 11
local h = 1
local my = 1
local mx = 1
local count = 0

local tw, th = term.getSize()

local function menuBtn(text, action, bg, fg)
    bg = bg or colours.green
    fg = fg or colours.white

    -- Calculate the number of rows that can fit in the terminal
    -- assuming each button is effectively it's height plus it's margin bottom
    local rowsPerColumn = math.floor(th / (h + my))

    -- Calculate the column and row for the current button
    local column = math.floor(count / rowsPerColumn)
    local row = count % rowsPerColumn

    -- Calculate the position based on column and row
    local x = 1 + mx + (w * column) + (mx * column)
    local y = 1 + my + (h * row) + (my * row)

    local btn = Button.new()
    btn:setText(text)
    btn:setSize(w, h)
    btn:setPos(x, y)
    btn:setBg(bg)
    btn:setFg(fg)

    count = count + 1

    return {
        btn = btn,
        action = action,
    }
end

local function main()
    local menu = {
        menuBtn("Trebor", function()
            shell.run("/trebor.lua")
        end),
        menuBtn("Attack!", function()
            shell.run("/att.lua")
        end),
        menuBtn("Nah...", function() end, colours.lightGrey, colours.black),
    }

    term.clear()
    term.setCursorPos(1, 1)

    parallel.waitForAny(
        table.unpack(arr.map(menu, function(item)
            return function()
                local btn = item["btn"]
                local action = item["action"]

                btn:render()
                btn:listen()

                term.clear()
                term.setCursorPos(1, 1)

                action()
            end
        end))
    )

    term.clear()
    term.setCursorPos(1, 1)
end

main()
