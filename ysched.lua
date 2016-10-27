local oldrequire = require
require = function(argname)
    if not getfenv().wait or not argname:match("ysched") then
        return oldrequire(argname)
    end
end

local target
if arg[1] then
    target = assert(loadfile(arg[1]))
elseif debug then
    target = debug.getinfo(3,'f').func -- cheeky hack to support require
else
    print "[SCHEDULER] Error: Either no arguments, or you're requiring this without the debug library."
    error "[SCHEDULER] See error message."
end

local    queue = {}
function queue:push(task, back)
    if back then
        self[#self+1] = task
        return
    end
    table.insert(self, 1, task)
end
function queue:pop()
    return table.remove(self, 1)
end

function spawn(_function)
    queue:push {
        ["coroutine"] = coroutine.create(_function),
        ["condition"] = false,
    }
end

function yield(condition, _function, ...)
    local args       = ...
    local truth      = condition
    local running    = coroutine.running()
    local _coroutine = _function and coroutine.create(function() _function() coroutine.resume(running) end) or coroutine.running()

    queue:push {
        ["coroutine"] = _coroutine,
        ["condition"] = truth,
        ["args"]      = args,
    }

    return coroutine.yield()
end

function wait(time)
    local dismissal = os.clock() + time
    return yield(function() return dismissal <= os.clock() end)
end

local function startscheduler()
    repeat
        local step = queue:pop()
        if step then
            if not step.condition or step.condition() then
                coroutine.resume(step.coroutine, step.args)
            else
                queue:push(step, true)
            end
        end
    until #queue    == 0
    debug.traceback = nil -- remove stacktrace from error in vanilla lua 
    error "[SCHEDULER] Execution complete." -- prevent script from running again when required. (side effect of require hack)
end

spawn(target) 
startscheduler()
