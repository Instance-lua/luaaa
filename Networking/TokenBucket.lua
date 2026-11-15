--Strict
--Made by instance.


local TokenBucket = {}
TokenBucket.__index = TokenBucket

function TokenBucket.new(capacity: number, refillRate: number, clock: (() -> number)?)
    assert(capacity > 0, "Capacity must be positive")
    assert(refillRate > 0, "Refill rate must be positive")

    local now = (clock or os.clock)()
    return setmetatable({
        Capacity = capacity,
        RefillRate = refillRate,
        Tokens = capacity,
        LastUpdate = now,
        Clock = clock or os.clock,
    }, TokenBucket)
end

function TokenBucket:_Refill()
    local now = self.Clock()
    local elapsed = math.max(0, now - self.LastUpdate)
    self.Tokens = math.min(self.Capacity, self.Tokens + elapsed * self.RefillRate)
    self.LastUpdate = now
end

function TokenBucket:Consume(amount: number?): boolean
    amount = amount or 1
    assert(amount > 0, "Amount must be positive")
    self:_Refill()

    if self.Tokens < amount then
        return false
    end

    self.Tokens -= amount
    return true
end

function TokenBucket:GetAvailable(): number
    self:_Refill()
    return self.Tokens
end

function TokenBucket:GetWaitTime(amount: number?): number
    amount = amount or 1
    self:_Refill()
    return math.max(0, amount - self.Tokens) / self.RefillRate
end

function TokenBucket:Reset()
    self.Tokens = self.Capacity
    self.LastUpdate = self.Clock()
end

return TokenBucket
