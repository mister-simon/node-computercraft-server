local pp           = require("cc.pretty").pretty_print
local arr          = require("/scripts/api/arr")

-- Manage args
local pathArg      = ({ ... })[1] or "/animation/"
local framerateArg = ({ ... })[2] or 8
local loopArg      = ({ ... })[3] or true

if type(loopArg) == "string" then
    if (loopArg == "false" or loopArg == "0") then
        loopArg = false
    elseif (loopArg == "true" or loopArg == "1") then
        loopArg = true
    else
        error("Loop arg (3) must be either (true/false) or (0/1)")
    end
end

assert(pathArg:match("^\/.+\/$"), "Path arg (1) must start and end with / - i.e. /animation/")
assert(tonumber(framerateArg) ~= nil, "Framerate arg (2) must be numeric")

-- Main stuff begins
local function allMonitors(fn)
    local cur = term.current()
    fn()

    arr.each({ peripheral.find("monitor") }, function(m)
        term.redirect(m)
        fn()
    end)

    term.redirect(cur)
end

local function listFrames(path)
    local frames = arr.filter(fs.list(path), function(file)
        return file:match("%d+\.nfp$")
    end)

    frames = arr.map(frames, function(frame, key)
        return {
            path = pathArg .. frame,
            key = tonumber(frame:match("(%d+).nfp"))
        }
    end)

    frames = arr.values(frames)

    table.sort(frames, function(a, b)
        return a.key < b.key
    end)

    return frames
end

local function renderFrame(frame)
    term.clear()
    paintutils.drawImage(assert(paintutils.loadImage(frame.path)), 2, 1)
    term.setBackgroundColour(colours.black)
    term.setCursorPos(1, 1)
end

local function main()
    local frames = listFrames(pathArg)

    for i, frame in ipairs(frames) do
        allMonitors(function() renderFrame(frame) end)
        sleep(1 / tonumber(framerateArg))
    end
end

repeat
    main()
until not loopArg

term.clear()
