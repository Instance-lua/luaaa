--Strict
--Made by instance.


local VersionedRecord = {}
VersionedRecord.__index = VersionedRecord

function VersionedRecord.new(initialData: {[string]: any}?)
    return setmetatable({
        _Data = table.clone(initialData or {}),
        _Version = 0,
    }, VersionedRecord)
end

function VersionedRecord:Get(key: string)
    return self._Data[key]
end

function VersionedRecord:Set(key: string, value: any, expectedVersion: number?)
    if expectedVersion ~= nil and expectedVersion ~= self._Version then
        return false, "Version conflict", self._Version
    end
    self._Data[key] = value
    self._Version += 1
    return true, self._Version
end

function VersionedRecord:Update(transform, expectedVersion: number?)
    if expectedVersion ~= nil and expectedVersion ~= self._Version then
        return false, "Version conflict", self._Version
    end
    local draft = table.clone(self._Data)
    local ok, result = pcall(transform, draft)
    if not ok then return false, result, self._Version end
    assert(typeof(draft) == "table", "Transform must preserve table")
    self._Data = draft
    self._Version += 1
    return true, result, self._Version
end

function VersionedRecord:Snapshot()
    return table.clone(self._Data), self._Version
end

return VersionedRecord
