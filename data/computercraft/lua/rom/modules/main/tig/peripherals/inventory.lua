local lib = {}

lib.findFirstFreeSlot = function(inv)
    local nextFree = #{inv.list()} + 1
    if nextFree > inv.size() then
        return nil
    end
    return nextFree
end

lib.findFirstItem = function(inv, item_id)
    local list = inv.list()

    for slot, item in pairs(list) do
        if item.name == item_id then
            return slot, item
        end
    end
end

--Pushes all items from one container to another.
--item_id filter is optional.
--Returns amount of items moved
lib.pushAllItems = function(from, to, item_id)
    local fromList = from.list()
    local count = 0

    if fromList == nil then return 0 end
	
	for slot, item in pairs(fromList) do
		if 
            (item_id ~= nil and item.name == item_id) 
            or 
            (item_id == nil) --Auto disable filter
        then
            local moved = from.pushItems(to.name, slot)
            if moved ~= nil then
                count = count + moved
            end
		end
	end

    return count
end


--Pushes all items from one container to another in parallel
--WARNING: Produces one event per filled slot. This can easily overwhelm
--the event queue! Use carefully.
--item_id filter is optional.
--Returns amount of items moved
lib.pushAllItemsParallel = function(from, to, item_id)
    local fromList = from.list()
    local count = 0

    if fromList == nil then return 0 end

    local funcs = {}
    for slot, item in pairs(fromList) do
        if 
            (item_id ~= nil and item.name == item_id) 
            or 
            (item_id == nil) --Auto disable filter
        then
            funcs[#funcs+1] = function()
                local moved = from.pushItems(to.name, slot)
                if moved ~= nil then
                    count = count + moved
                end
            end
        end
    end
    parallel.waitForAll(table.unpack(funcs))
    return count
end

--Pushes all items from one container to another with a limit.
--item_id filter is optional.
--Returns amount of items moved
lib.pushAllItemsLimit = function(from, to, item_id, limit)
    local fromList = from.list()
    local count = 0

    if fromList == nil then return 0 end
	
	for slot, item in pairs(fromList) do
		if 
            (item_id ~= nil and item.name == item_id) 
            or 
            (item_id == nil) --Auto disable filter
        then
            local moved = from.pushItems(to.name, slot, limit - count)
            if moved ~= nil then
                count = count + moved
                if count >= limit then
                    return count
                end
            end
		end
	end

    return count
end

--Pushes items based on a given predicate function
--Predicate is given item and slot
--Predicate returns should_move, limit (nil for no limit)
lib.pushAllItemsPredicate = function(from, to, predicate)
    local fromList = from.list()
	
	for slot, item in pairs(fromList) do
        local should_move, limit = predicate(item, slot)
		if should_move then 
			from.pushItems(to.name, slot, nil, limit)
		end
	end
end

--Pushes the first found item stack from one container to another
--limit and item_filter parameters are optional
lib.pushFirstItem = function(from, to, toSlot, limit, item_id)
	local fromList = from.list()
    print("TRYING TO PUSH")
	for fromSlot, item in pairs(fromList) do
        if 
            (item_id ~= nil and item_id == item.name)
            or
            (item_id == nil)
        then
            print("PUSHING")
            return from.pushItems(to.name, fromSlot, toSlot, limit)
        end
	end
end

--Counts all items in the given inventory
--item_id filter is optional
lib.countItems = function(inv, item_id)
    local list = inv.list()
	local count = 0
	for slot, item in pairs(list) do
		if 
            (item_id ~= nil and item_id == item.name)
            or
            (item_id == nil) 
        then
			count = count + item.count
		end
	end
	return count
end


--Returns a more detailed list
--Includes information from getItemDetail for all slots
lib.listDetail = function(inv)
    local list = inv.list()

    for slot, item in pairs(list) do
        local detail = inv.getItemDetail(slot)
        for k, v in pairs(detail) do
            item[k] = v
        end
    end

    return list
end


--Calculates an accurate fill percentage of an inventory
--Ranges from 0 - 1
lib.fillPercentage = function(inv)
    local slots = inv.size()
    local eachPercent = 1 / slots
    local list = inv.listDetail()
    local fullness = 0
    for i, item in pairs(list) do
        local slotPercent = item.count / item.maxCount
        fullness = fullness + (slotPercent * eachPercent)
    end
    return fullness
end

--Calculates an approximate fill percentage of an inventory
--Ranges from 0 - 1
lib.approxFillPercentage = function(inv)
    local slots = inv.size()
    local eachPercent = 1 / slots
    local list = inv.list()
    local fullness = 0
    for _, _ in pairs(list) do
        fullness = fullness + eachPercent
    end
    return fullness
end

lib.isEmpty = function(inv)
    return #(inv.list()) == 0
end

return lib