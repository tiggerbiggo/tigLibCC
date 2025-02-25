local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function createPronter()
    local index = 1

    return function()
        if index <= #alphabet then
            print(alphabet:sub(index, index))
            index = index + 1
        else
            print("All letters used")
        end
    end
end

return createPronter