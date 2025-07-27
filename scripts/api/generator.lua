local function splitFirst(first, ...)
    return first, { ... }
end

local Generator = {}
Generator.__index = Generator

function Generator.new(co)
    local instance = {
        co = co,
        runTask = false
    }

    instance.yield = function(...)
        return coroutine.yield(...)
    end

    instance.exec = function(callback, ...)
        instance.runTask = true
        return coroutine.yield(callback, ...)
    end

    return setmetatable(instance, Generator)
end

function Generator.from(toExecute)
    local co = coroutine.create(toExecute)
    return Generator.new(co)
end

function Generator:run()
    local isActive, results = splitFirst(self:resume(self.yield, self.exec))
    if not isActive then
        return nil
    end

    while self.runTask do
        self.runTask = false
        local task = results[1]
        isActive, results = splitFirst(self:resume(task(table.unpack(results, 2))))
    end

    return table.unpack(results)
end

function Generator:resume(...)
    return coroutine.resume(self.co, ...)
end

function Generator:close()
    return coroutine.close(self.co)
end

function Generator:dead()
    return coroutine.status(self.co) == "dead"
end

return {
    routine = Generator.from,
    create = function(toExecute)
        local generator = Generator.from(toExecute)
        return function() return generator:run() end
    end
}
