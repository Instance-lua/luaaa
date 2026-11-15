--Strict
--Made by instance.


local BinaryHeap = {}
BinaryHeap.__index = BinaryHeap

function BinaryHeap.new(comparator: ((any, any) -> boolean)?)
    return setmetatable({
        _Items = {},
        _Compare = comparator or function(left, right)
            return left < right
        end,
    }, BinaryHeap)
end

function BinaryHeap:_SiftUp(index: number)
    while index > 1 do
        local parent = math.floor(index / 2)
        if not self._Compare(self._Items[index], self._Items[parent]) then
            break
        end
        self._Items[index], self._Items[parent] = self._Items[parent], self._Items[index]
        index = parent
    end
end

function BinaryHeap:_SiftDown(index: number)
    local count = #self._Items
    while true do
        local left = index * 2
        local right = left + 1
        local best = index

        if left <= count and self._Compare(self._Items[left], self._Items[best]) then
            best = left
        end
        if right <= count and self._Compare(self._Items[right], self._Items[best]) then
            best = right
        end
        if best == index then
            break
        end

        self._Items[index], self._Items[best] = self._Items[best], self._Items[index]
        index = best
    end
end

function BinaryHeap:Push(value: any)
    table.insert(self._Items, value)
    self:_SiftUp(#self._Items)
end

function BinaryHeap:Pop()
    local count = #self._Items
    if count == 0 then
        return nil
    end

    local result = self._Items[1]
    local last = table.remove(self._Items)
    if #self._Items > 0 then
        self._Items[1] = last
        self:_SiftDown(1)
    end
    return result
end

function BinaryHeap:Peek()
    return self._Items[1]
end

function BinaryHeap:Size(): number
    return #self._Items
end

function BinaryHeap:IsEmpty(): boolean
    return #self._Items == 0
end

function BinaryHeap:Clear()
    table.clear(self._Items)
end

return BinaryHeap
