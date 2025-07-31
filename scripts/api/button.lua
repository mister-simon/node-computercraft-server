local str = require("cc.strings")

local Button = {}
Button.__index = Button

function Button.new(parent)
    local w, h = term.getSize()

    local instance = {
        x = 1,
        y = 1,
        w = w,
        h = h,
        bg = colours.black,
        fg = colours.white,
        text = "",
        parent = parent or term.current(),
        visibilityWasSet = false
    }

    instance.window = window.create(instance.parent, instance.x, instance.y, instance.w, instance.h, false)

    return setmetatable(instance, Button)
end

function Button:setPos(x, y)
    self.x = x
    self.y = y
    self.window.reposition(self.x, self.y)
end

function Button:setSize(w, h)
    self.w = w
    self.h = h
    self.window.reposition(self.x, self.y, self.w, self.h)
end

function Button:adopt(parent)
    self.parent = parent
    self.window.reposition(self.x, self.y, self.w, self.h, self.parent)
end

function Button:setText(text)
    self.text = text
end

function Button:setBg(bg)
    self.bg = bg
end

function Button:setFg(fg)
    self.fg = fg
end

function Button:render()
    if not self.visibilityWasSet then
        self:show()
    end

    self.window.setBackgroundColour(self.bg)
    self.window.setTextColour(self.fg)
    self.window.clear()

    local lines = str.wrap(self.text, self.w)
    for i = 1, #lines do
        local line = lines[i]
        local lineLength = string.len(line)
        local textX = math.floor((self.w - lineLength) / 2) + 1
        self.window.setCursorPos(textX, i)
        self.window.write(line)
    end
    self.window.scroll(-math.floor((self.h - #lines) / 2))
end

function Button:show()
    self.window.setVisible(true)
    self.visibilityWasSet = true
end

function Button:hide()
    self.window.setVisible(false)
    self.visibilityWasSet = true
end

function Button:listen()
    local event, button, x, y
    repeat
        event, button, x, y = os.pullEvent("mouse_click")
        local hitX = x >= self.x and x < self.x + self.w
        local hitY = y >= self.y and y < self.y + self.h
    until hitX and hitY

    return self, event, button, x, y
end

return Button
