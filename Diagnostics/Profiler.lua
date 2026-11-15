--Strict
--Made by instance.


local Profiler = {}
Profiler.__index = Profiler

function Profiler.new()
    return setmetatable({
        _Active = {},
        _Samples = {},
    }, Profiler)
end

function Profiler:Begin(label: string)
    assert(type(label) == "string" and #label > 0, "Label required")
    assert(self._Active[label] == nil, "Profiler label is already active")
    self._Active[label] = os.clock()
end

function Profiler:End(label: string)
    local startedAt = self._Active[label]
    assert(startedAt ~= nil, "Profiler label was not started")
    self._Active[label] = nil

    local elapsed = os.clock() - startedAt
    local samples = self._Samples[label]
    if not samples then
        samples = { Count = 0, Total = 0, Minimum = math.huge, Maximum = 0, Last = 0 }
        self._Samples[label] = samples
    end

    samples.Count += 1
    samples.Total += elapsed
    samples.Minimum = math.min(samples.Minimum, elapsed)
    samples.Maximum = math.max(samples.Maximum, elapsed)
    samples.Last = elapsed
    return elapsed
end

function Profiler:Measure(label: string, callback: (...any) -> ...any, ...)
    self:Begin(label)
    local arguments = table.pack(...)
    local packed = table.pack(xpcall(function()
        return callback(table.unpack(arguments, 1, arguments.n))
    end, debug.traceback))
    local elapsed = self:End(label)

    if not packed[1] then
        error(packed[2], 0)
    end
    return elapsed, table.unpack(packed, 2, packed.n)
end

function Profiler:GetStats(label: string)
    local samples = self._Samples[label]
    if not samples then
        return nil
    end
    return {
        Count = samples.Count,
        Total = samples.Total,
        Average = samples.Total / samples.Count,
        Minimum = samples.Minimum,
        Maximum = samples.Maximum,
        Last = samples.Last,
    }
end

function Profiler:GetAllStats()
    local result = {}
    for label in pairs(self._Samples) do
        result[label] = self:GetStats(label)
    end
    return result
end

function Profiler:Reset(label: string?)
    if label then
        self._Samples[label] = nil
        self._Active[label] = nil
    else
        table.clear(self._Samples)
        table.clear(self._Active)
    end
end

return Profiler
