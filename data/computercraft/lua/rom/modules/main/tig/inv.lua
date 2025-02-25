local lib = {}

local function dbg(str)
    if _G.TIG_DEBUG ~= nil then
        print(str)
    end
end


local function findRequire(types)
    local requirePath = "tig.peripherals."
    for k, v in pairs(types) do
        if type(v) == "string" then
            v = v:lower() --MC Datapacks don't support uppercase characters.
            dbg(requirePath .. v)
            
            local ok, got = pcall(require, requirePath .. v)
            
            if ok then
                dbg(type(got))
                return got
            end
        end
    end
    return nil
end

local function addMeta(itm)
    local mt = getmetatable(itm)
    
    local sharedFuncs = findRequire(mt.types)
    
    itm.name = mt.name
    
    if sharedFuncs ~= nil then
        mt.__index = function(tbl, key)
            if sharedFuncs[key] then
                return function(...)
                    return sharedFuncs[key](tbl, ...)
                end
            end
            return nil
        end
    end
    setmetatable(itm, mt)
end

local mappedInventories = nil

function lib.loadMappings(tigFiles)
    mappedInventories = tigFiles.readInventoryMapping()
    mappedInventories = lib.wrapNamedList(mappedInventories)
end

function lib.wrap(name)
    local wrapped = peripheral.wrap(name)
    if wrapped then
        addMeta(wrapped)
    end
    return wrapped
end

function lib.find(type)
	local found = {peripheral.find(type)}
	for index, item in pairs(found) do
		addMeta(item)
	end
	return found
end

function lib.findFirst(type)
    local found = peripheral.find(type)
    if found then
        addMeta(found)
    end
    return found
end

function lib.wrapAll()
    local names = peripheral.getNames()
    local wrapped = {}

    for i, name in pairs(names) do
        wrapped[#wrapped+1] = lib.wrap(name)
    end

    return wrapped
end

-- Attempts to wrap all of the values within a table
--  {
--      ["nickname"] = "real:id"
--  }
-- Intended to be used alongside tig.files.readInventoryMapping
function lib.wrapNamedList(list)
    local output = {}
    for nick, real in pairs(list) do
        output[nick] = lib.wrap(real)
    end
    return output
end

-- Attempts to wrap all of the values within a group
--  {
--      ["groupname"] = {
--          pnames = {
--              ["real:name"] = "real:name"
--          }
--      }
--  }
-- Intended to be used alongside tig.files.readGroupMapping
function lib.wrapGroups(groups)
    local newGroups = {}
    for gname, group in pairs(groups) do
        local wrapped = {}
        for pname in pairs(group.pnames) do
            wrapped[pname] = lib.wrap(pname)
        end
        newGroups[gname] = wrapped
    end
    return newGroups
end

--Predicate is given inv, index
--Predicate returns should_add
function lib.findPredicate(predicate)
    local allPeripherals = lib.wrapAll()
    local found = {}
	for index, inv in pairs(allPeripherals) do
        if predicate(inv, index) then
		    addMeta(inv)
            found[#found+1] = inv
        end
	end
	return found
end

return lib