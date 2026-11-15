--Strict
--Made by instance.


local WeightedRandom = require(script.Parent.Parent.Utilities.WeightedRandom)
local RewardTable = {}
RewardTable.__index = RewardTable

function RewardTable.new(entries: {any}, random: Random?)
    local self = setmetatable({ _Picker = WeightedRandom.new(random), _Definitions = {} }, RewardTable)
    for _, entry in ipairs(entries) do
        assert(type(entry.Id) == "string", "Reward id required")
        assert(type(entry.Weight) == "number" and entry.Weight > 0, "Reward weight must be positive")
        assert(self._Definitions[entry.Id] == nil, "Duplicate reward id")
        self._Definitions[entry.Id] = table.clone(entry)
        self._Picker:Add(entry.Id, entry.Weight)
    end
    return self
end

function RewardTable:Roll()
    local id = self._Picker:Choose()
    if not id then return nil end
    return table.clone(self._Definitions[id])
end

function RewardTable:GetTotalWeight(): number
    return self._Picker:GetTotalWeight()
end

function RewardTable:GetDefinition(id: string)
    local definition = self._Definitions[id]
    return definition and table.clone(definition) or nil
end

return RewardTable
