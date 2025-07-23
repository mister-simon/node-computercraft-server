local passbackToken = { _token = "why-tho" }

-- Just a bunch of helper functions
-- Because the output from the coroutine / passback can be a bit tricky
-- output = { success, iteration data | passbackToken, passbackFunction? | more data... }

local function isOk(output)
    return output and output[1]
end

local function isResult(output)
    return isOk(output) and (output[2] ~= passbackToken)
end

local function isPassbackFunction(output)
    return isOk(output) and (output[2] == passbackToken)
end

local function getPassbackFunction(output)
    if isPassbackFunction() then
        return output[3]
    end
    return nil
end

local function getResult(output)
    if isResult(output) then
        return table.unpack(output, 2)
    end
    return nil
end

local function coroutineIterator(co)
    return function()
        local output, passback

        repeat
            if isPassbackFunction(output) then
                passback = getPassbackFunction(output)()
            end

            output = { coroutine.resume(co, passback) }
        until isResult(output) or not isOk(output)

        return getResult(output)
    end
end

return {
    passbackToken = passbackToken,
    coroutineIterator = coroutineIterator
}