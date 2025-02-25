local Element = require("tig.gui.element")

return function (text, x, y, w, h)
    local label = Element(x,y,w,h)
    label.text = text
    label.bg = colors.black
    label.fg = colors.white
    label.draw = function(ctx, rx, ry)
        local mon = ctx.mon
        mon.setBackgroundColor(label.bg)
        mon.setTextColor(label.fg)
        mon.setCursorPos(label.x + rx, label.y + ry)
        mon.write(label.text or "")
    end

    return label
end