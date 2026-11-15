--Strict
--Made by instance.


local LRUCache = {}
LRUCache.__index = LRUCache

function LRUCache.new(capacity: number)
    assert(capacity > 0 and capacity % 1 == 0, "Capacity must be a positive integer")
    return setmetatable({
        Capacity = capacity,
        _Values = {},
        _Order = {},
        _Index = {},
    }, LRUCache)
end

function LRUCache:_Touch(key)
    local oldIndex = self._Index[key]
    if oldIndex then table.remove(self._Order, oldIndex) end
    table.insert(self._Order, 1, key)
    for index, currentKey in ipairs(self._Order) do self._Index[currentKey] = index end
end

function LRUCache:Get(key)
    local value = self._Values[key]
    if value ~= nil then self:_Touch(key) end
    return value
end

function LRUCache:Set(key, value)
    self._Values[key] = value
    self:_Touch(key)
    local evicted = nil
    if #self._Order > self.Capacity then
        evicted = table.remove(self._Order)
        self._Values[evicted] = nil
        self._Index[evicted] = nil
        for index, currentKey in ipairs(self._Order) do self._Index[currentKey] = index end
    end
    return evicted
end

function LRUCache:Remove(key)
    if self._Values[key] == nil then return false end
    self._Values[key] = nil
    table.remove(self._Order, self._Index[key])
    self._Index[key] = nil
    for index, currentKey in ipairs(self._Order) do self._Index[currentKey] = index end
    return true
end

function LRUCache:Clear()
    table.clear(self._Values)
    table.clear(self._Order)
    table.clear(self._Index)
end

function LRUCache:Size(): number
    return #self._Order
end

return LRUCache
