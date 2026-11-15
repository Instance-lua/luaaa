--Strict
--Made by instance.


local GuiVisibility = {}
GuiVisibility.__index = GuiVisibility

function GuiVisibility.new(target: GuiObject | ScreenGui)
    assert(target:IsA("GuiObject") or target:IsA("ScreenGui"), "Expected GUI instance")
    return setmetatable({ Target = target, _Visible = target.Enabled ~= false and target.Visible ~= false }, GuiVisibility)
end

function GuiVisibility:IsVisible(): boolean
    return self._Visible
end

function GuiVisibility:SetVisible(visible: boolean)
    self._Visible = visible
    if self.Target:IsA("ScreenGui") then
        self.Target.Enabled = visible
    else
        self.Target.Visible = visible
    end
end

function GuiVisibility:Toggle()
    self:SetVisible(not self._Visible)
    return self._Visible
end

function GuiVisibility:Destroy()
    self.Target = nil
end

return GuiVisibility
