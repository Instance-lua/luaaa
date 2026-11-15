--Strict
--Made by instance.


local WeightedRandom = {}
WeightedRandom.__index = WeightedRandom

function WeightedRandom.new(random: Random?)
    return setmetatable({
        _Random = random or Random.new(),
        _Entries = {},
        _TotalWeight = 0,
        _Dirty = false,
    }, WeightedRandom)
end

function WeightedRandom:Add(value: any, weight: number)
    assert(type(weight) == "number" and weight > 0 and weight < math.huge, "Weight must be finite and positive")
    table.insert(self._Entries, { Value = value, Weight = weight })
    self._TotalWeight += weight
    self._Dirty = true
end

function WeightedRandom:Remove(value: any): boolean
    for index = #self._Entries, 1, -1 do
        local entry = self._Entries[index]
        if entry.Value == value then
            self._TotalWeight -= entry.Weight
            table.remove(self._Entries, index)
            self._Dirty = true
            return true
        end
    end
    return false
end

function WeightedRandom:Choose()
    if #self._Entries == 0 or self._TotalWeight <= 0 then
        return nil
    end

    local roll = self._Random:NextNumber(0, self._TotalWeight)
    local cursor = 0
    for _, entry in ipairs(self._Entries) do
        cursor += entry.Weight
        if roll <= cursor then
            return entry.Value
        end
    end
    return self._Entries[#self._Entries].Value
end

function WeightedRandom:GetTotalWeight(): number
    return self._TotalWeight
end

function WeightedRandom:GetEntries()
    local copy = {}
    for index, entry in ipairs(self._Entries) do
        copy[index] = { Value = entry.Value, Weight = entry.Weight }
    end
    return copy
end

function WeightedRandom:Clear()
    table.clear(self._Entries)
    self._TotalWeight = 0
    self._Dirty = false
end

return WeightedRandom
