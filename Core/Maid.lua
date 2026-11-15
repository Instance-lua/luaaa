--Strict
--Made by instance.


local Maid = {}
Maid.__index = Maid

local function cleanupTask(taskValue: any)
    local kind = typeof(taskValue)
    if kind == "RBXScriptConnection" then
        taskValue:Disconnect()
    elseif kind == "Instance" then
        taskValue:Destroy()
    elseif type(taskValue) == "function" then
        taskValue()
    elseif type(taskValue) == "table" then
        if type(taskValue.Destroy) == "function" then
            taskValue:Destroy()
        elseif type(taskValue.Disconnect) == "function" then
            taskValue:Disconnect()
        elseif type(taskValue.Cancel) == "function" then
            taskValue:Cancel()
        end
    end
end

function Maid.new()
    return setmetatable({
        _Tasks = {},
        _NextId = 0,
        _Destroyed = false,
    }, Maid)
end

function Maid:Give(taskValue: any, key: any?): any
    assert(not self._Destroyed, "Maid has been destroyed")
    assert(taskValue ~= nil, "Cannot give nil to Maid")

    if key ~= nil then
        self:Remove(key)
        self._Tasks[key] = taskValue
        return taskValue
    end

    self._NextId += 1
    self._Tasks[self._NextId] = taskValue
    return taskValue
end

function Maid:Remove(key: any)
    local taskValue = self._Tasks[key]
    if taskValue == nil then
        return
    end
    self._Tasks[key] = nil
    local ok, message = pcall(cleanupTask, taskValue)
    if not ok then
        warn("[Maid] Cleanup failed: " .. tostring(message))
    end
end

function Maid:DoCleaning()
    local tasks = self._Tasks
    self._Tasks = {}

    local orderedKeys = {}
    for key in pairs(tasks) do
        table.insert(orderedKeys, key)
    end
    table.sort(orderedKeys, function(left, right)
        if type(left) == "number" and type(right) == "number" then
            return left > right
        end
        return tostring(left) > tostring(right)
    end)

    for _, key in ipairs(orderedKeys) do
        local ok, message = pcall(cleanupTask, tasks[key])
        if not ok then
            warn("[Maid] Cleanup failed: " .. tostring(message))
        end
    end
end

function Maid:Count(): number
    local count = 0
    for _ in pairs(self._Tasks) do
        count += 1
    end
    return count
end

function Maid:Destroy()
    if self._Destroyed then
        return
    end
    self:DoCleaning()
    self._Destroyed = true
end

return Maid
