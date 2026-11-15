--Strict
--Made by instance.


local CooldownManager = {}
CooldownManager.__index = CooldownManager

function CooldownManager.new(clock: (() -> number)?)
    return setmetatable({ _EndsAt = {}, Clock = clock or os.clock }, CooldownManager)
end

function CooldownManager:Start(key: any, duration: number)
    assert(duration >= 0, "Duration cannot be negative")
    self._EndsAt[key] = self.Clock() + duration
end

function CooldownManager:IsReady(key: any): boolean
    local endTime = self._EndsAt[key]
    if not endTime then return true end
    if self.Clock() >= endTime then
        self._EndsAt[key] = nil
        return true
    end
    return false
end

function CooldownManager:GetRemaining(key: any): number
    local endTime = self._EndsAt[key]
    if not endTime then return 0 end
    local remaining = endTime - self.Clock()
    if remaining <= 0 then self._EndsAt[key] = nil return 0 end
    return remaining
end

function CooldownManager:TryStart(key: any, duration: number): boolean
    if not self:IsReady(key) then return false end
    self:Start(key, duration)
    return true
end

function CooldownManager:Clear(key: any?)
    if key == nil then table.clear(self._EndsAt) else self._EndsAt[key] = nil end
end

return CooldownManager
