--Strict
--Made by instance.


local RateWindow = {}
RateWindow.__index = RateWindow

function RateWindow.new(limit: number, windowSeconds: number, clock: (() -> number)?)
    assert(limit > 0 and windowSeconds > 0, "Limit and window must be positive")
    return setmetatable({
        Limit = limit,
        Window = windowSeconds,
        Clock = clock or os.clock,
        _Events = {},
    }, RateWindow)
end

function RateWindow:_Prune(now: number)
    local cutoff = now - self.Window
    local firstValid = 1
    while firstValid <= #self._Events and self._Events[firstValid] <= cutoff do
        firstValid += 1
    end
    if firstValid > 1 then
        local remaining = {}
        for index = firstValid, #self._Events do table.insert(remaining, self._Events[index]) end
        self._Events = remaining
    end
end

function RateWindow:TryConsume(): boolean
    local now = self.Clock()
    self:_Prune(now)
    if #self._Events >= self.Limit then return false end
    table.insert(self._Events, now)
    return true
end

function RateWindow:GetRemaining(): number
    self:_Prune(self.Clock())
    return math.max(0, self.Limit - #self._Events)
end

function RateWindow:Reset()
    table.clear(self._Events)
end

return RateWindow
