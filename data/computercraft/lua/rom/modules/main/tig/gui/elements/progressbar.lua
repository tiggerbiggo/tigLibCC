local Element = require("tig.gui.element")

local midChar = string.char(149)

return function (x, y, w, h)
    local bar = Element(x,y,w,h)

    bar.bg = colors.black
    bar.fg = colors.white
    bar.draw = function(ctx, rx, ry)
        local mon = ctx.mon
        for i=1, w do
            
        end
        mon.setBackgroundColor(bar.bg)
        mon.setTextColor(bar.fg)
        mon.setCursorPos(bar.x + rx, bar.y + ry)
        mon.write(label.text or "")
    end

    return label
end