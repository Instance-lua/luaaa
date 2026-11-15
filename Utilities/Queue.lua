--Strict
--Made by instance.


local Queue = {}
Queue.__index = Queue

function Queue.new()
    return setmetatable({
        _Items = {},
        _First = 1,
        _Last = 0,
    }, Queue)
end

function Queue:Enqueue(value: any)
    self._Last += 1
    self._Items[self._Last] = value
    return self._Last
end

function Queue:Dequeue()
    if self._First > self._Last then
        return nil
    end
    local value = self._Items[self._First]
    self._Items[self._First] = nil
    self._First += 1

    if self._First > self._Last then
        self._First = 1
        self._Last = 0
    end
    return value
end

function Queue:Peek()
    return self._Items[self._First]
end

function Queue:IsEmpty(): boolean
    return self._First > self._Last
end

function Queue:Size(): number
    return math.max(0, self._Last - self._First + 1)
end

function Queue:Clear()
    table.clear(self._Items)
    self._First = 1
    self._Last = 0
end

return Queue
