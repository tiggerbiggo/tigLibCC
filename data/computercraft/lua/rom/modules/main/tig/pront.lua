--This is a stupid idea, but it basically prints a new letter
--every time you call the function, meaning you can "trace"
--with print statements by counting how many calls you should have gotten.

--It's dumb. Don't bother using it.

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
