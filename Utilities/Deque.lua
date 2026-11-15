--Strict
--Made by instance.


local Deque = {}
Deque.__index = Deque

function Deque.new()
    return setmetatable({ _Items = {}, _First = 0, _Last = -1 }, Deque)
end

function Deque:PushBack(value)
    self._Last += 1
    self._Items[self._Last] = value
end

function Deque:PushFront(value)
    self._First -= 1
    self._Items[self._First] = value
end

function Deque:PopFront()
    if self:IsEmpty() then return nil end
    local value = self._Items[self._First]
    self._Items[self._First] = nil
    self._First += 1
    return value
end

function Deque:PopBack()
    if self:IsEmpty() then return nil end
    local value = self._Items[self._Last]
    self._Items[self._Last] = nil
    self._Last -= 1
    return value
end

function Deque:IsEmpty(): boolean return self._First > self._Last end
function Deque:Size(): number return math.max(0, self._Last - self._First + 1) end

function Deque:Clear()
    table.clear(self._Items)
    self._First = 0
    self._Last = -1
end

return Deque
