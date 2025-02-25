local lib = {}

function lib.openOrCreateFile(path, mode)
    local dir = fs.getDir(path)
    if not fs.exists(dir) then
        fs.makeDir(dir)
    end
    return fs.open(path, mode)
end

--textutils.serialize(obj, {["compact"]=true})
--textutils.unserialize(str)

function lib.serializeToFile(path, obj)
    local file = lib.openOrCreateFile(path, "w")
    if file then
        file.write(textutils.serialize(obj, {["compact"]=true}))
        file.close()
    else
        error("Could not open file for writing: " .. path)
    end
end

function lib.unserializeFromFile(path)
    local file = lib.openOrCreateFile(path, "r")
    if file then
        local content = file.readAll()
        file.close()
        if content and content ~= "" then
            return textutils.unserialize(content)
        end
    end
    return {}
end

--Reads the inventory file from the tig_inv_setup program
function lib.readInventoryMapping()
    return lib.unserializeFromFile("tig/inventories.txt")
end

--Reads the group file from the tig_inv_setup program
function lib.readGroupMapping()
    return lib.unserializeFromFile("tig/groups.txt")
end

return lib