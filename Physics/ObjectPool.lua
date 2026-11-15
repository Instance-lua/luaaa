--Strict
--Made by instance.


local ObjectPool = {}
ObjectPool.__index = ObjectPool

function ObjectPool.new(template: Instance, parent: Instance, initialSize: number?, maximumSize: number?)
    assert(template and template:IsA("Instance"), "Template instance required")
    assert(parent and parent:IsA("Instance"), "Parent instance required")

    local self = setmetatable({}, ObjectPool)
    self.Template = template
    self.Parent = parent
    self.MaximumSize = maximumSize or 100
    self._Available = {}
    self._InUse = {}
    self._Destroyed = false

    for _ = 1, math.max(0, initialSize or 0) do
        local instance = self:_Create()
        table.insert(self._Available, instance)
    end
    return self
end

function ObjectPool:_Create(): Instance
    local instance = self.Template:Clone()
    instance.Parent = self.Parent
    instance:SetAttribute("PoolActive", false)
    return instance
end

function ObjectPool:Acquire(): Instance?
    assert(not self._Destroyed, "ObjectPool has been destroyed")
    local instance = table.remove(self._Available)
    if not instance then
        local total = #self._Available
        for _ in pairs(self._InUse) do
            total += 1
        end
        if total >= self.MaximumSize then
            return nil
        end
        instance = self:_Create()
    end

    self._InUse[instance] = true
    instance:SetAttribute("PoolActive", true)
    return instance
end

function ObjectPool:Release(instance: Instance): boolean
    if not self._InUse[instance] then
        return false
    end
    self._InUse[instance] = nil
    if instance.Parent == nil then
        instance:Destroy()
        return false
    end
    instance:SetAttribute("PoolActive", false)
    if instance:IsA("BasePart") then
        instance.AssemblyLinearVelocity = Vector3.zero
        instance.AssemblyAngularVelocity = Vector3.zero
    end
    table.insert(self._Available, instance)
    return true
end

function ObjectPool:GetCounts()
    local inUse = 0
    for _ in pairs(self._InUse) do
        inUse += 1
    end
    return #self._Available, inUse
end

function ObjectPool:Destroy()
    if self._Destroyed then
        return
    end
    self._Destroyed = true
    for _, instance in ipairs(self._Available) do
        instance:Destroy()
    end
    for instance in pairs(self._InUse) do
        instance:Destroy()
    end
    table.clear(self._Available)
    table.clear(self._InUse)
end

return ObjectPool
