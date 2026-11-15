--Strict
--Made by instance.


local Signal = require(script.Parent.Signal)
local EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter.new()
    return setmetatable({ _Events = {}, _Destroyed = false }, EventEmitter)
end

function EventEmitter:GetEvent(name: string)
    assert(not self._Destroyed, "Emitter destroyed")
    assert(type(name) == "string" and #name > 0, "Event name required")
    if not self._Events[name] then self._Events[name] = Signal.new() end
    return self._Events[name]
end

function EventEmitter:On(name: string, callback)
    return self:GetEvent(name):Connect(callback)
end

function EventEmitter:Once(name: string, callback)
    return self:GetEvent(name):Once(callback)
end

function EventEmitter:Emit(name: string, ...)
    local event = self._Events[name]
    if event then event:Fire(...) end
end

function EventEmitter:Remove(name: string)
    local event = self._Events[name]
    if not event then return false end
    event:Destroy()
    self._Events[name] = nil
    return true
end

function EventEmitter:Destroy()
    if self._Destroyed then return end
    self._Destroyed = true
    for _, event in pairs(self._Events) do event:Destroy() end
    table.clear(self._Events)
end

return EventEmitter
