local ti = require("tig.inv")
local tf = require("tig.files")

local groupFile = "tig/groups.txt"

local groupMap = tf.unserializeFromFile(groupFile)

local peripheralNames = {}

local function updatePeripheralNames()
    peripheralNames = {}
    local invs = ti.wrapAll()

    for i, inv in pairs(invs) do
        peripheralNames[inv.name] = inv.name
    end
end



local function headerPrint(str)
    term.clear()

    term.setCursorPos(1, 1)
    print("Tig's group manager;")
    print("")
    print(str)
end

local function listGroups(count)
    headerPrint("Groups: ")
    print("")

    local wrote = false
    local written = 0

    for name in pairs(groupMap) do
        print(name)
        wrote = true
        written = written + 1
        if written >= count then
            print("Press enter to show more...")
            written = 0
            read()
            headerPrint("Groups: ")
            print("")
        end
    end
end

local function listNames(group, count)
    local wrote = false

    for _, pname in pairs(group.pnames) do
        local exists = peripheralNames[pname]
        if exists ~= nil then
            print(" --> " .. pname)
        else
            print(" -X- " .. pname)
        end
        wrote = true
    end

    if not wrote then
        print("No mappings defined.")
    end
end

local function completeFn(list)
    return function(partial)
        local matches = {}
        for name, _ in pairs(list) do
            if name:sub(1, #partial) == partial then
                table.insert(matches, name:sub(#partial+1))
            end
        end
        return #matches > 0 and matches or nil
    end
end

local function mainLoop()
    while true do
        updatePeripheralNames()
        listGroups(8)
        print("")
        print("Type a group name to add or edit it, or X to exit")
        local gname = read()
        if gname == "x" or gname == "X" then
            return
        end

        local group = groupMap[gname]

        if group == nil then
            group = {}
            group.name = gname
            group.pnames = {}
        end

        local function redraw()
            headerPrint("Setting peripheral map for group \"" .. gname .. "\"")
            print("Peripherals currently mapped to this group:")
            print("")

            listNames(group, 8)
            
            print("")
            print("Newly connected peripherals will appear in this list")
            print("Or type to manually add / remove")
            print("type X to exit, or DELETE to delete this group")
        end

        local function sync()
            groupMap[gname] = group
            tf.serializeToFile(groupFile, groupMap)
        end

        local function readLoop()
            while true do
                redraw()
                local combinedList = {}

                for k, v in pairs(peripheralNames) do
                    combinedList[k] = v
                end

                for k, v in pairs(group.pnames) do
                    combinedList[k] = v
                end

                local real = read(nil, nil, completeFn(combinedList))

                if real == "x" or real == "X" then
                    sync()
                    return
                elseif real == "DELETE" then
                    sync()
                    return
                elseif group.pnames[real] ~= nil then
                    group.pnames[real] = nil
                elseif peripheralNames[real] ~= nil then
                    group.pnames[real] = real
                else
                    print("Invalid peripheral.")
                    sleep(0.5)
                end
                sync()
            end
        end

        local function peripheralAttach()
            while true do
                local event, side = os.pullEvent("peripheral")
                updatePeripheralNames()
                group.pnames[side] = side
                sync()
                redraw()
            end
        end

        local function peripheralDetach()
            while true do
                local event, side = os.pullEvent("peripheral-detach")
                updatePeripheralNames()
                group.pnames[side] = nil
                sync()
                redraw()
            end
        end
        
        parallel.waitForAny(readLoop, peripheralAttach, peripheralDetach)
    end
end

mainLoop()