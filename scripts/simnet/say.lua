return function(side, quiet)
    return function(msg)
        rednet.open(side)
        rednet.broadcast(msg, "simnet")
        if quiet then return end
    end
end
