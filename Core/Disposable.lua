--Strict
--Made by instance.


local Disposable = {}
Disposable.__index = Disposable

function Disposable.new()
    return setmetatable({ _Disposed = false, _Callbacks = {} }, Disposable)
end

function Disposable:Add(callback: () -> ())
    assert(not self._Disposed, "Disposable has already been disposed")
    assert(type(callback) == "function", "Expected function")
    table.insert(self._Callbacks, callback)
    return callback
end

function Disposable:IsDisposed(): boolean
    return self._Disposed
end

function Disposable:Dispose()
    if self._Disposed then return end
    self._Disposed = true
    for index = #self._Callbacks, 1, -1 do
        local ok, message = pcall(self._Callbacks[index])
        if not ok then warn("[Disposable] " .. tostring(message)) end
        self._Callbacks[index] = nil
    end
end

return Disposable
