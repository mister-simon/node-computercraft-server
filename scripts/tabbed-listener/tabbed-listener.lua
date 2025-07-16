-- Listens to rednet broadcasts. Creates multishell tabs for incoming message streams.
local args = {...}
local protocol = args[0] or "simnet"
local side = args[1] or "back"

local hostTerm = term.current()
local items = {}

function addToMenu(id)
    if items[id] == nil then
        items[id] = {
            window = createWindow(id),
            lastMessage = nil,
        }
    end

    return items[id]
end

function createWindow(id)
    local mainWidth, mainHeight = term.getSize()

    local offsetY = math.floor(mainHeight / 2)
    local windowHeight = mainHeight - offsetY

    return window.create(hostTerm, 1, offsetY, mainWidth, windowHeight, false)
end

function consumeMessage(id, message)
    local item = items[id]

    term.redirect(item.window)
    window.print(message)
    term.redirect(hostTerm)
end

local function listen()
    local id, message = rednet.receive(protocol)
    addToMenu(id)
    consumeMessage(id, message)
end

local function menu()
    local event, button, x, y = os.pullEvent("mouse_click")
    print(("The mouse button %s was pressed at %d, %d"):format(button, x, y))
end

function main()
    rednet.open(side)

    while true do
        parallel.waitForAny(listen, menu)
    end    
end


main()