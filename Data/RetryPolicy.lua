--Strict
--Made by instance.


local RetryPolicy = {}
RetryPolicy.__index = RetryPolicy

function RetryPolicy.new(options: any?)
    options = options or {}
    return setmetatable({
        MaxAttempts = options.MaxAttempts or 4,
        BaseDelay = options.BaseDelay or 0.5,
        MaxDelay = options.MaxDelay or 8,
        Multiplier = options.Multiplier or 2,
        Jitter = options.Jitter == nil and 0.2 or options.Jitter,
        Random = options.Random or Random.new(),
    }, RetryPolicy)
end

function RetryPolicy:GetDelay(attempt: number): number
    assert(attempt >= 1, "Attempt must be positive")
    local exponential = math.min(self.BaseDelay * self.Multiplier ^ (attempt - 1), self.MaxDelay)
    local spread = exponential * self.Jitter
    return math.max(0, self.Random:NextNumber(exponential - spread, exponential + spread))
end

function RetryPolicy:Run(operation: (number) -> ...any, shouldRetry: ((any) -> boolean)?)
    local lastResult
    local lastError

    for attempt = 1, self.MaxAttempts do
        local packed = table.pack(pcall(operation, attempt))
        if packed[1] then
            local result = table.pack(table.unpack(packed, 2, packed.n))
            if shouldRetry == nil or not shouldRetry(result[1]) then
                return true, table.unpack(result, 1, result.n)
            end
            lastResult = result
        else
            lastError = packed[2]
            if shouldRetry and not shouldRetry(lastError) then
                return false, lastError
            end
        end

        if attempt < self.MaxAttempts then
            task.wait(self:GetDelay(attempt))
        end
    end

    return false, lastError or lastResult
end

return RetryPolicy
