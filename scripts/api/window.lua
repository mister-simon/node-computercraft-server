local function toWindow(wrapped)
    return function(fn)
        local cur = term.current()
        term.redirect(wrapped)
        fn()
        term.redirect(cur)
    end
end

local function hitTest(testWindow)
    return function(x, y)
        local tx, ty = testWindow.getPosition()
        local tw, th = testWindow.getSize()
        local hitX = x >= tx and x < tx + tw
        local hitY = y >= ty and y < ty + th
        return hitX and hitY
    end
end

return {
    hitTest = hitTest,
    toWindow = toWindow
}
