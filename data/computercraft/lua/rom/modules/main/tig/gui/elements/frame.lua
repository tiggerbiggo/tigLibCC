local Element = require("tig.gui.element")

return function (x, y, w, h, col)
    local frame = Element(x,y,w,h)
    frame.children = {}
    frame.childrenVisible = true
    frame.col = col

    frame.addChild = function(child)
        frame.children[#frame.children+1] = child
    end

    frame.draw = function(ctx, rx, ry)
        if frame.col ~= nil then
            ctx.mon.drawRect(
                frame.x + rx,
                frame.y + ry,
                frame.w,
                frame.h,
                frame.col
            )
        end
        if frame.childrenVisible then
            for _, child in pairs(frame.children) do
                if type(child.draw) == "function"  and child.visible then
                    child.draw(ctx, rx + frame.x - 1, ry + frame.y - 1)
                end
            end
        end
    end
    return frame
end