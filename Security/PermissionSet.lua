--Strict
--Made by instance.


local PermissionSet = {}
PermissionSet.__index = PermissionSet

function PermissionSet.new()
    return setmetatable({
        _Grants = {},
        _Denials = {},
    }, PermissionSet)
end

function PermissionSet:Grant(subject: string, permission: string)
    assert(subject ~= "" and permission ~= "", "Subject and permission are required")
    self._Grants[subject] = self._Grants[subject] or {}
    self._Grants[subject][permission] = true
    if self._Denials[subject] then
        self._Denials[subject][permission] = nil
    end
end

function PermissionSet:Deny(subject: string, permission: string)
    assert(subject ~= "" and permission ~= "", "Subject and permission are required")
    self._Denials[subject] = self._Denials[subject] or {}
    self._Denials[subject][permission] = true
end

function PermissionSet:Revoke(subject: string, permission: string)
    if self._Grants[subject] then
        self._Grants[subject][permission] = nil
    end
    if self._Denials[subject] then
        self._Denials[subject][permission] = nil
    end
end

function PermissionSet:Has(subject: string, permission: string): boolean
    local denials = self._Denials[subject]
    if denials and (denials[permission] or denials["*"]) then
        return false
    end

    local grants = self._Grants[subject]
    if grants and (grants[permission] or grants["*"]) then
        return true
    end

    local globalGrants = self._Grants["*"]
    return globalGrants ~= nil and (globalGrants[permission] or globalGrants["*"]) == true
end

function PermissionSet:ClearSubject(subject: string)
    self._Grants[subject] = nil
    self._Denials[subject] = nil
end

function PermissionSet:GetSnapshot()
    return {
        Grants = table.clone(self._Grants),
        Denials = table.clone(self._Denials),
    }
end

return PermissionSet
