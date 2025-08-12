-- Igor Skoric - http://lua-users.org/wiki/SimpleRound
local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    if num >= 0 then
        return math.floor(num * mult + 0.5) / mult
    else
        return math.ceil(num * mult - 0.5) / mult
    end
end

local function toShortString(number)
    if number >= 1000000 then
        return "1M+"
    end

    if number > 1000 then
        return round(number / 1000) .. "K"
    end

    return tostring(number)
end

return {
    round = round,
    toShortString = toShortString
}
