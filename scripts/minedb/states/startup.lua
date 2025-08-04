local NAS = require("/scripts/minedb/nas-class")
local arr = require("/scripts/api/arr")
local ls = require("/scripts/api/localstorage")

return function()
    local mainWindow = term.current()

    term.clear()
    term.setCursorPos(1, 1)

    -- Select a monitor as the "main" window?
    local monitors = arr.map(
        { peripheral.find('monitor') },
        function(modem)
            return peripheral.getName(modem)
        end
    )

    if #monitors ~= 0 then
        -- Allow "local" term to be used
        table.insert(monitors, "local")
        local monitor = ls.ensure("minedb", "monitor", monitors)
        mainWindow = peripheral.wrap(monitor)
    end

    term.redirect(mainWindow)

    term.clear()
    term.setCursorPos(1, 1)

    -- Draw a logo :)
    local logo = assert(paintutils.loadImage("/scripts/minedb/states/minedb.nfp"));
    paintutils.drawImage(logo, 2, 2)
    mainWindow.setBackgroundColour(colours.black)


    -- Intentionally create a single line window at the bottom of the screen
    -- In case we're projecting to a monitor at this point. Input should be easier.
    local tw, th = term.getSize()
    local subwindow = window.create(mainWindow, 1, th, tw, 1)
    term.redirect(subwindow)

    -- Prompt for or retrieve from settings a modem side + create the NAS
    local modemSides = arr.map(
        { peripheral.find('modem') },
        function(modem)
            return peripheral.getName(modem)
        end
    )

    local nas = NAS.new(ls.ensure("minedb", "side", modemSides))

    -- Prompt for or retrieve from settings the io chest
    local input = ls.ensure("minedb", "input", nas.remotes)
    nas:setInputName(input)
    nas:setOutputName(input)

    -- Hooray
    term.write("All set!")
    sleep(3)

    term.redirect(mainWindow)

    term.clear()
    term.setCursorPos(1, 1)

    return nas
end
