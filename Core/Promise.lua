--Strict
--Made by instance.


local Promise = {}
Promise.__index = Promise

local PENDING = "Pending"
local RESOLVED = "Resolved"
local REJECTED = "Rejected"
local CANCELLED = "Cancelled"

local function settle(self, status, value)
    if self._Status ~= PENDING then
        return
    end
    self._Status = status
    self._Value = value
    local handlers = self._Handlers
    self._Handlers = {}
    for _, handler in ipairs(handlers) do
        task.spawn(handler, status, value)
    end
end

function Promise.new(executor)
    assert(type(executor) == "function", "Promise executor must be a function")
    local self = setmetatable({
        _Status = PENDING,
        _Value = nil,
        _Handlers = {},
        _CancelHandlers = {},
    }, Promise)

    local function resolve(value)
        if value == self then
            settle(self, REJECTED, "A promise cannot resolve to itself")
        elseif getmetatable(value) == Promise then
            value:Then(resolve, function(reason)
                settle(self, REJECTED, reason)
            end)
        else
            settle(self, RESOLVED, value)
        end
    end

    local function reject(reason)
        settle(self, REJECTED, reason)
    end

    local function onCancel(callback)
        assert(type(callback) == "function", "Cancel handler must be a function")
        if self._Status == CANCELLED then
            callback()
        elseif self._Status == PENDING then
            table.insert(self._CancelHandlers, callback)
        end
    end

    task.spawn(function()
        local ok, message = xpcall(function()
            executor(resolve, reject, onCancel)
        end, debug.traceback)
        if not ok then
            reject(message)
        end
    end)

    return self
end

function Promise.resolve(value)
    return Promise.new(function(resolve)
        resolve(value)
    end)
end

function Promise.reject(reason)
    return Promise.new(function(_, reject)
        reject(reason)
    end)
end

function Promise:Then(onResolved, onRejected)
    return Promise.new(function(resolve, reject, onCancel)
        local cancelled = false
        onCancel(function()
            cancelled = true
        end)

        local function handle(status, value)
            if cancelled then
                return
            end
            local callback = status == RESOLVED and onResolved or onRejected
            if not callback then
                if status == RESOLVED then
                    resolve(value)
                else
                    reject(value)
                end
                return
            end

            local ok, result = xpcall(function()
                return callback(value)
            end, debug.traceback)

            if not ok then
                reject(result)
            else
                resolve(result)
            end
        end

        if self._Status == PENDING then
            table.insert(self._Handlers, handle)
        else
            task.spawn(handle, self._Status, self._Value)
        end
    end)
end

function Promise:Catch(onRejected)
    return self:Then(nil, onRejected)
end

function Promise:Finally(callback)
    return self:Then(function(value)
        callback()
        return value
    end, function(reason)
        callback()
        error(reason)
    end)
end

function Promise:Await()
    if self._Status == RESOLVED then
        return true, self._Value
    elseif self._Status == REJECTED or self._Status == CANCELLED then
        return false, self._Value
    end

    local thread = coroutine.running()
    table.insert(self._Handlers, function(status, value)
        task.spawn(thread, status == RESOLVED, value)
    end)
    return coroutine.yield()
end

function Promise:Cancel(reason)
    if self._Status ~= PENDING then
        return false
    end
    settle(self, CANCELLED, reason or "Cancelled")
    for _, callback in ipairs(self._CancelHandlers) do
        task.spawn(callback)
    end
    table.clear(self._CancelHandlers)
    return true
end

function Promise:GetStatus()
    return self._Status
end

return Promise
