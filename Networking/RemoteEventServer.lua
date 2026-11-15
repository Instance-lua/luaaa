--Strict
--Made by instance.


local RemoteEventServer = {}
RemoteEventServer.__index = RemoteEventServer

function RemoteEventServer.new(remoteEvent: RemoteEvent, options: any?)
    assert(remoteEvent:IsA("RemoteEvent"), "Expected RemoteEvent")
    options = options or {}
    local self = setmetatable({
        Remote = remoteEvent,
        Validator = options.Validator,
        Authorizer = options.Authorizer,
        RateLimiterFactory = options.RateLimiterFactory,
        _Handlers = {},
        _PlayerLimits = {},
        _Connection = nil,
        _Destroyed = false,
    }, RemoteEventServer)

    self._Connection = remoteEvent.OnServerEvent:Connect(function(player, ...)
        self:_Handle(player, ...)
    end)
    return self
end

function RemoteEventServer:_Handle(player: Player, ...)
    if self._Destroyed then return end
    local arguments = table.pack(...)

    if self.Authorizer then
        local ok, allowed = pcall(self.Authorizer, player, table.unpack(arguments, 1, arguments.n))
        if not ok or not allowed then return end
    end

    if self.Validator then
        local ok, valid = pcall(self.Validator, player, table.unpack(arguments, 1, arguments.n))
        if not ok or not valid then return end
    end

    for _, handler in ipairs(self._Handlers) do
        local ok, message = xpcall(function()
            handler(player, table.unpack(arguments, 1, arguments.n))
        end, debug.traceback)
        if not ok then warn("[RemoteEventServer] Handler failed: " .. tostring(message)) end
    end
end

function RemoteEventServer:Connect(handler)
    assert(not self._Destroyed, "Remote wrapper destroyed")
    assert(type(handler) == "function", "Handler must be a function")
    table.insert(self._Handlers, handler)
    local connected = true
    return {
        Disconnect = function()
            if not connected then return end
            connected = false
            local index = table.find(self._Handlers, handler)
            if index then table.remove(self._Handlers, index) end
        end,
    }
end

function RemoteEventServer:FireClient(player: Player, ...)
    assert(not self._Destroyed, "Remote wrapper destroyed")
    self.Remote:FireClient(player, ...)
end

function RemoteEventServer:FireAllClients(...)
    assert(not self._Destroyed, "Remote wrapper destroyed")
    self.Remote:FireAllClients(...)
end

function RemoteEventServer:Destroy()
    if self._Destroyed then return end
    self._Destroyed = true
    if self._Connection then self._Connection:Disconnect() end
    table.clear(self._Handlers)
    table.clear(self._PlayerLimits)
    self.Remote = nil
end

return RemoteEventServer
