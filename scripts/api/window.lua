local function toWindow(wrapped)
    return function(fn)
        local cur = term.current()
        term.redirect(wrapped)
        fn()
        term.redirect(cur)
    end
end

return {
    toWindow = toWindow
}
