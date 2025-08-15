local arr = require("/scripts/api/arr")
local pp = require "cc.pretty".pretty_print

local function unstow(nas, queue)
    local output = nas:getOutput()

    arr.each(queue, function(job)
        local collection = job.collection
        local quantity = job.quantity

        print(collection.displayName(), quantity)
        local remaining = collection.pushTo(output, quantity)
        print("Moved " .. (job.quantity - remaining))
        job.quantity = remaining
    end)

    print("Cool")
end

return unstow
