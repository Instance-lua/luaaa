--Strict
--Made by instance.


local Signal = {}
Signal.__index = Signal

export type Connection = {
    Connected: boolean,
    Disconnect: (self: Connection) -> (),
}

local ConnectionMethods = {}
ConnectionMethods.__index = ConnectionMethods

function ConnectionMethods:Disconnect()
    if not self.Connected then
        return
    end
    self.Connected = false
    local signal = self.Signal
    if signal then
        signal._Listeners[self] = nil
        signal._Count -= 1
    end
    self.Signal = nil
    self.Callback = nil
end

function Signal.new()
    local self = setmetatable({}, Signal)
    self._Listeners = {}
    self._Count = 0
    self._Destroyed = false
    self._Firing = 0
    return self
end

function Signal:Connect(callback: (...any) -> ())
    assert(not self._Destroyed, "Cannot connect to a destroyed signal")
    assert(type(callback) == "function", "Callback must be a function")

    local connection = setmetatable({
        Connected = true,
        Callback = callback,
        Signal = self,
    }, ConnectionMethods)

    self._Listeners[connection] = true
    self._Count += 1
    return connection
end

function Signal:Once(callback: (...any) -> ())
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        callback(...)
    end)
    return connection
end

function Signal:Fire(...)
    if self._Destroyed or self._Count == 0 then
        return
    end

    local arguments = table.pack(...)
    local snapshot = {}
    for connection in pairs(self._Listeners) do
        table.insert(snapshot, connection)
    end

    self._Firing += 1
    for _, connection in ipairs(snapshot) do
        if connection.Connected and self._Listeners[connection] then
            local ok, message = xpcall(function()
                connection.Callback(table.unpack(arguments, 1, arguments.n))
            end, debug.traceback)
            if not ok then
                warn("[Signal] Listener failed:\n" .. tostring(message))
            end
        end
    end
    self._Firing -= 1
end

function Signal:Wait()
    assert(not self._Destroyed, "Cannot wait on a destroyed signal")
    local thread = coroutine.running()
    local connection
    connection = self:Once(function(...)
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function Signal:GetConnectionCount(): number
    return self._Count
end

function Signal:DisconnectAll()
    local snapshot = {}
    for connection in pairs(self._Listeners) do
        table.insert(snapshot, connection)
    end
    for _, connection in ipairs(snapshot) do
        connection:Disconnect()
    end
end

function Signal:Destroy()
    if self._Destroyed then
        return
    end
    self:DisconnectAll()
    self._Destroyed = true
end

return Signal
