--Strict
--Made by instance.


local RemoteFunctionClient = {}
RemoteFunctionClient.__index = RemoteFunctionClient

function RemoteFunctionClient.new(remoteFunction: RemoteFunction, timeout: number?)
    assert(remoteFunction:IsA("RemoteFunction"), "Expected RemoteFunction")
    return setmetatable({
        Remote = remoteFunction,
        Timeout = timeout or 10,
        Destroyed = false,
    }, RemoteFunctionClient)
end

function RemoteFunctionClient:Invoke(...)
    assert(not self.Destroyed, "RemoteFunctionClient has been destroyed")
    local arguments = table.pack(...)
    local completed = false
    local succeeded = false
    local result

    task.spawn(function()
        local packed = table.pack(pcall(function()
            return self.Remote:InvokeServer(table.unpack(arguments, 1, arguments.n))
        end))
        succeeded = packed[1]
        result = table.pack(table.unpack(packed, 2, packed.n))
        completed = true
    end)

    local deadline = os.clock() + self.Timeout
    while not completed and os.clock() < deadline do
        task.wait()
    end

    if not completed then
        return false, "Remote invocation timed out"
    end
    if not succeeded then
        return false, result[1]
    end
    return true, table.unpack(result, 1, result.n)
end

function RemoteFunctionClient:Destroy()
    self.Destroyed = true
    self.Remote = nil
end

return RemoteFunctionClient
