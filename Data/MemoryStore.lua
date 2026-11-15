--Strict
--Made by instance.


local MemoryStore = {}
MemoryStore.__index = MemoryStore

function MemoryStore.new(clock: (() -> number)?)
    return setmetatable({ _Entries = {}, Clock = clock or os.clock }, MemoryStore)
end

function MemoryStore:Set(key: string, value: any, ttl: number?)
    assert(type(key) == "string" and #key > 0, "Key required")
    self._Entries[key] = {
        Value = value,
        ExpiresAt = ttl and self.Clock() + math.max(0, ttl) or nil,
    }
end

function MemoryStore:Get(key: string)
    local entry = self._Entries[key]
    if not entry then return nil end
    if entry.ExpiresAt and self.Clock() >= entry.ExpiresAt then
        self._Entries[key] = nil
        return nil
    end
    return entry.Value
end

function MemoryStore:Has(key: string): boolean
    return self:Get(key) ~= nil
end

function MemoryStore:Remove(key: string)
    local existed = self._Entries[key] ~= nil
    self._Entries[key] = nil
    return existed
end

function MemoryStore:Prune()
    local now = self.Clock()
    local removed = 0
    for key, entry in pairs(self._Entries) do
        if entry.ExpiresAt and now >= entry.ExpiresAt then
            self._Entries[key] = nil
            removed += 1
        end
    end
    return removed
end

function MemoryStore:Count(): number
    self:Prune()
    local count = 0
    for _ in pairs(self._Entries) do count += 1 end
    return count
end

function MemoryStore:Clear()
    table.clear(self._Entries)
end

return MemoryStore
