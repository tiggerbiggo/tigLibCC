local lib = {}

--Writes blank characters to the end of the current line
--Also 
lib.clearToLine = function(mon)
    local x, y = mon.getCursorPos()
    local w = mon.getSize()

    mon.setCursorPos(x, y)
    mon.write(string.rep(" ", w - x + 1))
    mon.setCursorPos(1, y+1)
end

lib.clearToEnd = function(mon)
    local x, y = mon.getCursorPos()
    local w, h = mon.getSize()

    -- Clear the current line first
    lib.clearToLine(mon)

    -- Clear the remaining lines
    for i = y + 1, h do
        mon.setCursorPos(1, i)
        mon.write(string.rep(" ", w))
    end
end

lib.print = function(mon, str)
    -- Write the string to the monitor
    mon.write(str)
    
    -- Get the current cursor position
    local x, y = mon.getCursorPos()
    
    -- Set the cursor position to the beginning of the next line
    mon.setCursorPos(1, y + 1)
end

--draws a rectangle with only the bg colour
lib.drawRect = function(monitor, x, y, w, h, bg)
    bg = bg or 0
    local text = string.rep(" ", w)
    local bgStr = string.rep(bg, w)
    
    for j = 1, h do
        monitor.setCursorPos(x, y + j - 1)
        monitor.blit(text, bgStr, bgStr)
    end
end

return lib