--Strict
--Made by instance.


local Stack = {}
Stack.__index = Stack

function Stack.new(capacity: number?)
    if capacity ~= nil then
        assert(capacity >= 1 and capacity % 1 == 0, "Capacity must be a positive integer")
    end
    return setmetatable({
        _Items = {},
        _Count = 0,
        _Capacity = capacity,
    }, Stack)
end

function Stack:Push(value: any): boolean
    if self._Capacity and self._Count >= self._Capacity then
        return false
    end
    self._Count += 1
    self._Items[self._Count] = value
    return true
end

function Stack:Pop()
    if self._Count == 0 then
        return nil
    end
    local value = self._Items[self._Count]
    self._Items[self._Count] = nil
    self._Count -= 1
    return value
end

function Stack:Peek()
    return self._Items[self._Count]
end

function Stack:Size(): number
    return self._Count
end

function Stack:IsEmpty(): boolean
    return self._Count == 0
end

function Stack:Clear()
    table.clear(self._Items)
    self._Count = 0
end

return Stack
