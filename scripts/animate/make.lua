local pathArg = ({ ... })[1] or "/animation/"

assert(pathArg:match("^\/.+\/$"), "Path must start and end with / - i.e. /animation/")

local count   = 1
local another = false

repeat
    shell.run("paint " .. pathArg .. count)
    print("Added frame " .. count)
    print("Add another frame? ('Y' or '')")

    another = (read(nil, nil, nil, "Y") ~= "")

    if another then
        count = count + 1
        shell.run("cp " .. pathArg .. (count - 1) .. '.nfp ' .. pathArg .. count .. '.nfp')
    end
until not another

print("Added " .. count .. " frames")
