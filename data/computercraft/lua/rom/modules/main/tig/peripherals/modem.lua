local lib = {}

lib.getMessage = function(modem, channel)
    while true do
        local event, side, receiveChannel, replyChannel, message, distance = os.pullEvent("modem_message")
        if receiveChannel == channel then
            return message
        end
    end
end

lib.getTable = function(modem, channel)
    while true do
        local message = modem.getMessage(channel)
        local ok, got = pcall(textutils.unserialize, message)
        if ok then return got end
    end
end

lib.sendTable = function(modem, channel, obj)
    local ser = textutils.serialize(obj)
    modem.transmit(channel, channel, ser)
end

lib.setRpcReceiverName = function(modem, receiver_name)
    modem.receiver_name = receiver_name
end

lib.registerRpc = function(modem, command, procedure)
    modem.rpc = modem.rpc or {}

    modem.rpc[command] = procedure
end

lib.registerRpcTable = function(modem, commands)
    for name, func in pairs(commands) do
        modem.registerRpc(name, func)
    end
end

lib.callRpc = function(modem, command, channel, receiver_name, params)
    local msg = {}
    msg.command = command
    msg.receiver_name = receiver_name
    if params ~= nil then
        for k, v in pairs(params) do
            msg[k] = v
        end
    end
    modem.sendTable(channel, msg)
end

lib.rpcLoop = function(modem, channel)
    if modem.rpc == nil then
        print("ERROR: RPC not defined for modem: " .. modem.name)
        return
    end
    local processStack = {}
    local function listenLoop()
        while true do
            local msg = modem.getTable(channel)
            if 
                modem.receiver_name == nil
                or
                msg.receiver_name == nil
                or
                modem.receiver_name == msg.receiver_name
            then
                local cmd = modem.rpc[msg.command]
                if cmd ~= nil then
                    processStack[#processStack+1] = {cmd = cmd, msg = msg}
                    os.queueEvent("rpcWake")
                end
            end
        end
    end
    local function processLoop()
        while true do
            local process
            repeat
                process = processStack[#processStack]
                if process ~= nil then
                    process.cmd(process.msg)
                    processStack[#processStack] = nil
                end
            until process == nil
            os.pullEvent("rpcWake")
        end
    end

    parallel.waitForAll(listenLoop, processLoop)
end

return lib