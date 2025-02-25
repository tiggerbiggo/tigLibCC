
return function (x, y, w, h)
    local elem = {
        x = x or 1,
        y = y or 1,
        w = w or 1,
        h = h or 1,
        visible = true,
        consume = false --if consume is true, we only
    }

    elem.clickEvents = {}

    elem.tryClick = function(ctx, clickX, clickY)
        local inRange = clickX >= elem.x and clickX < elem.x + elem.w 
                        and
                        clickY >= elem.y and clickY < elem.y + elem.h
        local consume = elem.consume
        if inRange then
            if #elem.clickEvents >=1 then
                for _, event in pairs(elem.clickEvents) do
                    ctx.clicked(event)
                end
            end
            if elem.children ~= nil then
                for _, child in pairs(elem.children) do
                    child.tryClick(ctx, (clickX - elem.x) + 1, (clickY - elem.y) + 1)
                end
            end
        end
    end

    elem.onClick = function(f)
        elem.clickEvents[#elem.clickEvents+1] = f
    end

    return elem
end