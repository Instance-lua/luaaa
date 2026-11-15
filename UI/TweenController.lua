--Strict
--Made by instance.


local TweenService = game:GetService("TweenService")

local TweenController = {}
TweenController.__index = TweenController

function TweenController.new()
    return setmetatable({
        _Active = {},
        _Destroyed = false,
    }, TweenController)
end

function TweenController:Play(instance: Instance, tweenInfo: TweenInfo, goals: {[string]: any}, key: string?)
    assert(not self._Destroyed, "TweenController has been destroyed")
    local tweenKey = key or tostring(instance)
    local previous = self._Active[tweenKey]
    if previous then
        previous:Cancel()
        previous:Destroy()
    end

    local tween = TweenService:Create(instance, tweenInfo, goals)
    self._Active[tweenKey] = tween
    tween.Completed:Once(function()
        if self._Active[tweenKey] == tween then
            self._Active[tweenKey] = nil
        end
        tween:Destroy()
    end)
    tween:Play()
    return tween
end

function TweenController:Cancel(key: string)
    local tween = self._Active[key]
    if not tween then
        return false
    end
    self._Active[key] = nil
    tween:Cancel()
    tween:Destroy()
    return true
end

function TweenController:CancelAll()
    for key, tween in pairs(self._Active) do
        self._Active[key] = nil
        tween:Cancel()
        tween:Destroy()
    end
end

function TweenController:Destroy()
    if self._Destroyed then
        return
    end
    self._Destroyed = true
    self:CancelAll()
end

return TweenController
