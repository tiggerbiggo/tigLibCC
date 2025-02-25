local lib = {}

lib.dictItems = function(inv)
    local dict = {}
    for _, item in pairs(inv.listItems()) do
        dict[item.name] = item
    end
    return dict
end

return lib