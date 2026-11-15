--Strict
--Made by instance.


local Set = {}
Set.__index = Set

function Set.new(values: {any}?)
    local self = setmetatable({ _Values = {}, _Count = 0 }, Set)
    for _, value in ipairs(values or {}) do self:Add(value) end
    return self
end

function Set:Add(value: any): boolean
    if self._Values[value] then return false end
    self._Values[value] = true
    self._Count += 1
    return true
end

function Set:Remove(value: any): boolean
    if not self._Values[value] then return false end
    self._Values[value] = nil
    self._Count -= 1
    return true
end

function Set:Has(value: any): boolean return self._Values[value] == true end
function Set:Count(): number return self._Count end
function Set:ToArray()
    local result = {}
    for value in pairs(self._Values) do table.insert(result, value) end
    return result
end

function Set:Union(other)
    local result = Set.new(self:ToArray())
    for value in pairs(other._Values) do result:Add(value) end
    return result
end

function Set:Intersect(other)
    local result = Set.new()
    for value in pairs(self._Values) do if other:Has(value) then result:Add(value) end end
    return result
end

function Set:Difference(other)
    local result = Set.new()
    for value in pairs(self._Values) do if not other:Has(value) then result:Add(value) end end
    return result
end

function Set:Clear()
    table.clear(self._Values)
    self._Count = 0
end

return Set
