--This is a modified version of parallel.lua.

-- SPDX-FileCopyrightText: 2017 Daniel Ratcliffe
--
-- SPDX-License-Identifier: LicenseRef-CCPL

--[[- A simple way to run several functions at once.

Functions are not actually executed simultaneously, but rather this API will
automatically switch between them whenever they yield (e.g. whenever they call
[`coroutine.yield`], or functions that call that - such as [`os.pullEvent`] - or
functions that call that, etc - basically, anything that causes the function
to "pause").

Each function executed in "parallel" gets its own copy of the event queue,
and so "event consuming" functions (again, mostly anything that causes the
script to pause - eg [`os.sleep`], [`rednet.receive`], most of the [`turtle`] API,
etc) can safely be used in one without affecting the event queue accessed by
the other.


> [!WARNING]
> When using this API, be careful to pass the functions you want to run in
> parallel, and _not_ the result of calling those functions.
>
> For instance, the following is correct:
>
> ```lua
> local function do_sleep() sleep(1) end
> parallel.waitForAny(do_sleep, rednet.receive)
> ```
>
> but the following is **NOT**:
>
> ```lua
> local function do_sleep() sleep(1) end
> parallel.waitForAny(do_sleep(), rednet.receive)
> ```

@module parallel
@since 1.2
]]

local manager = {}

function manager.addFnToThreads(threads, fn)
    local barrier_ctx = { co = coroutine.running() }
    threads[#threads+1] = { co = coroutine.create(fn), filter = nil }
end

function manager.createThreads(...)
    local functions = table.pack(...)
    local threads = {}
    for i = 1, functions.n, 1 do
        local fn = functions[i]
        if type(fn) ~= "function" then
            error("bad argument #" .. i .. " (function expected, got " .. type(fn) .. ")", 3)
        end
        manager.addToThreads(threads, fn)
    end

    return threads
end

function manager.processThreads(threads)
    local event = { n = 0 }
    while true do
        for i, thread in pairs(threads) do
            if type(i) == "number" and i >= 1 then
                if thread and (thread.filter == nil or thread.filter == event[1] or event[1] == "terminate") then
                    local ok, param = coroutine.resume(thread.co, table.unpack(event, 1, event.n))
                    if ok then
                        thread.filter = param
                    else
                        error(param, 0)
                    end
    
                    if coroutine.status(thread.co) == "dead" then
                        threads[i] = nil
                    end
                end
            end
        end
        event = table.pack(os.pullEventRaw())
    end
end

return manager