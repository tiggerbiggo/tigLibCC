local ti = require("tig.inv")
local tf = require("tig.files")

local invFile = "tig/inventories.txt"

local inventoryMap = tf.unserializeFromFile(invFile)

local invNames = {}

local invs

local function resetInvList()
    invs = ti.wrapAll()

    for i, inv in pairs(invs) do
        invNames[inv.name] = true
    end
end

local function headerPrint(str)
    term.clear()

    term.setCursorPos(1, 1) -- The first column of line 1
    print("Tig's peripheral manager;")
    print("")
    print(str)
end

local function listPeripherals(count)
    print("")

    local wrote = false
    local written = 0

    for i, peripheral in pairs(invs) do
        print(peripheral.name)
        wrote = true
        written = written + 1
        if written >= count then
            print("")
            print("Press enter to show more...")
            read()
        end
    end

    if not wrote then
        print("No peripherals connected.")
    end
end

local function listNames(count)
    headerPrint("Nicknames: ")
    print("")

    local wrote = false
    local written = 0

    -- Find the maximum length of the nicknames
    local maxNickLength = 0
    for nick, _ in pairs(inventoryMap) do
        if #nick > maxNickLength then
            maxNickLength = #nick
        end
    end

    for nick, real in pairs(inventoryMap) do
        local exists = invNames[real]
        local paddedNick = nick .. string.rep(" ", maxNickLength - #nick)
        if exists then
            print(paddedNick .. " --> " .. real)
        else
            print(paddedNick .. " -X- " .. real)
        end
        wrote = true
        written = written + 1
        if written >= count then
            written = 0
            print("Press enter to show more...")
            read()
        end
    end

    if not wrote then
        print("No names defined.")
    end
end

local function completeFn(partial)
    local matches = {}
    for name, _ in pairs(invNames) do
        if name:sub(1, #partial) == partial then
            table.insert(matches, name:sub(#partial+1))
        end
    end
    return #matches > 0 and matches or nil
end

local function mainLoop()
    while true do
        resetInvList()
        listNames(8)
        print("")
        print("Type a name to add or edit it, or X to exit")
        local nick = read()
        if nick == "x" or nick == "X" then
            return
        end

        local added = false
        while not added do
            headerPrint("Setting name map for \"" .. nick .. "\"")
            print("")
            print("Input the inventory id to map to or connect a peripheral")
            print("type X to exit, or DELETE to delete this mapping")
            
            local function inputLoop()
                local real = read(nil, nil, completeFn)

                if real == "x" or real == "X" then
                    added = true
                elseif real == "DELETE" then
                    added = true

                    inventoryMap[nick] = nil

                    headerPrint("Inventory mapping deleted.")
                elseif invNames[real] then
                    added = true

                    inventoryMap[nick] = real

                    headerPrint("Inventory mapping added.")
                else
                    headerPrint("No inventory with that name found: " .. real)
                end
                sleep(1.5)
            end

            local function peripheralAttach()
                local event, side = os.pullEvent("peripheral")
                inventoryMap[nick] = side
                added = true
            end

            parallel.waitForAny(inputLoop, peripheralAttach)
        end
        tf.serializeToFile(invFile, inventoryMap)
    end
end

mainLoop()