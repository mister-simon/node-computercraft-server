local NAS = require("/scripts/minedb/nas-class")
local arr = require("/scripts/api/arr")
local ls = require("/scripts/api/localstorage")
local toWindow = require("/scripts/api/window").toWindow

return function(compWindow)
    local monitorWindow

    -- Some wrapper functions to make writing to different outputs easier
    local toComp = toWindow(compWindow)
    local toMon = function(fn) end
    local toBoth = function(fn)
        toComp(fn)
        toMon(fn)
    end

    -- Select a monitor as the "main" window?
    local monitors = arr.map(
        { peripheral.find('monitor') },
        function(modem)
            return peripheral.getName(modem)
        end
    )

    term.clear()
    term.setCursorPos(1, 1)

    if #monitors ~= 0 then
        -- Allow "local" term to be used
        table.insert(monitors, "local")
        local monitor = ls.ensure("minedb", "monitor", monitors)
        monitorWindow = peripheral.wrap(monitor)
        toMon = function(fn)
            local cur = term.current()
            term.redirect(monitorWindow)
            fn()
            term.redirect(cur)
        end
    end

    toBoth(function()
        term.clear()
        term.setCursorPos(1, 1)

        -- Draw a logo :)
        local logo = assert(paintutils.loadImage("/scripts/minedb/states/minedb.nfp"));
        paintutils.drawImage(logo, 2, 2)
        term.setBackgroundColour(colours.black)
        print("\n")
    end)


    -- Create a terminal region below the logo
    local tw, th = term.getSize()
    local toBtm = toWindow(window.create(compWindow, 1, 13, tw, th - 13))

    local nas

    toBtm(function()
        -- Prompt for or retrieve from settings a modem side + create the NAS
        local modemSides = arr.map(
            { peripheral.find('modem') },
            function(modem)
                return peripheral.getName(modem)
            end
        )

        nas = NAS.new(ls.ensure("minedb", "side", modemSides))

        -- Prompt for or retrieve from settings the io chest
        local input = ls.ensure("minedb", "input", nas.remotes)
        nas:setInputName(input)
        nas:setOutputName(input)
    end)

    toBoth(function()
        -- Hooray
        print("All set!")
    end)

    sleep(3)

    term.clear()
    term.setCursorPos(1, 1)

    local windows = {
        comp = compWindow,
        mon = monitorWindow,
        toComp = toComp,
        toMon = toMon,
        toBoth = toBoth,
    }

    return nas, windows
end
