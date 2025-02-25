local manager = require("tig.tasks.manager")

local function clickLoop(ctx)
    while true do
        local event, side, x, y = coroutine.yield("monitor_touch")
        if side == ctx.mon.name then
            for i, element in ipairs(ctx.elements) do
                element.tryClick(ctx, x, y)
            end
        end
    end
end

local function drawLoop(ctx)
    while true do
        for i, element in pairs(ctx.elements) do
            if type(element.draw) == "function" and element.visible then
                element.draw(ctx, 0, 0)
            end
        end
        local selfCheck = nil
        while selfCheck ~= ctx.mon.name do
            local _, obj = coroutine.yield("redraw")
            selfCheck = obj.mon.name
            print(ctx, selfCheck)
        end
    end
end

local function redraw(ctx)
    os.queueEvent("redraw", ctx)
end

return function(monitor)
    local threads = {}
    local ctx = {}
    ctx.mon = monitor
    ctx.elements = {}
    ctx.startLoop = function(fns)
        fns = fns or {}
        for _, fn in pairs(fns) do
            manager.addFnToThreads(threads, fn)
        end
        local function f()
            clickLoop(ctx)
        end
        manager.addFnToThreads(threads, f)
        
        f = function()
            drawLoop(ctx)
        end
        manager.addFnToThreads(threads, f)
        
        manager.processThreads(threads)
    end
    ctx.clicked = function(f)
        manager.addFnToThreads(threads, f)
    end
    ctx.addChild = function(child)
        ctx.elements[#ctx.elements+1] = child
    end
    ctx.redraw = function()
        redraw(ctx)
    end
    return ctx
end