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

function Button.make(text, x, y, bg, fg, parent)
    bg = bg or colours.green
    fg = fg or colours.white

    local btn = Button.new(parent)
    local w = text:len()
    btn:setText(text)
    btn:setSize(w, 1)
    btn:setBg(bg)
    btn:setFg(fg)
    btn:setPos(x, y)

    return btn
end

function Button:setPos(x, y)
    self.x = x
    self.y = y
    self:reposition()
end

function Button:setX(x)
    self.x = x
    self:reposition()
end

function Button:setY(x)
    self.y = y
    self:reposition()
end

function Button:setSize(w, h)
    self.w = w
    self.h = h
    self:reposition()
end

function Button:setWidth(w)
    self.w = w
    self:reposition()
end

function Button:setHeight(h)
    self.h = h
    self:reposition()
end

function Button:adopt(parent)
    self.parent = parent
    self:reposition()
end

function Button:reposition()
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

function Button:hitTest(x, y)
    local hitX = x >= self.x and x < self.x + self.w
    local hitY = y >= self.y and y < self.y + self.h
    return hitX and hitY
end

function Button:listen()
    local event, button, x, y
    repeat
        event, button, x, y = os.pullEvent("mouse_click")
    until self:hitTest(x, y)

    return self, event, button, x, y
end

return Button
