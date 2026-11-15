--Strict
--Made by instance.


local Signal = require(script.Parent.Signal)

local State = {}
State.__index = State

function State.new(initialValue: any, equals: ((any, any) -> boolean)?)
    local self = setmetatable({}, State)
    self._Value = initialValue
    self._Equals = equals or function(left, right)
        return left == right
    end
    self.Changed = Signal.new()
    self._Destroyed = false
    self._Version = 0
    return self
end

function State:Get()
    assert(not self._Destroyed, "State has been destroyed")
    return self._Value
end

function State:Set(nextValue: any): boolean
    assert(not self._Destroyed, "State has been destroyed")
    local previousValue = self._Value
    if self._Equals(previousValue, nextValue) then
        return false
    end
    self._Value = nextValue
    self._Version += 1
    self.Changed:Fire(nextValue, previousValue, self._Version)
    return true
end

function State:Update(transform: (any) -> any)
    assert(type(transform) == "function", "Transform must be a function")
    return self:Set(transform(self:Get()))
end

function State:Subscribe(callback: (any, any, number) -> (), fireImmediately: boolean?)
    local connection = self.Changed:Connect(callback)
    if fireImmediately then
        callback(self._Value, nil, self._Version)
    end
    return connection
end

function State:GetVersion(): number
    return self._Version
end

function State:Destroy()
    if self._Destroyed then
        return
    end
    self._Destroyed = true
    self.Changed:Destroy()
end

return State
