--Strict
--Made by instance.


local AttachmentBinder = {}
AttachmentBinder.__index = AttachmentBinder

function AttachmentBinder.new(part: BasePart)
    assert(part:IsA("BasePart"), "Expected BasePart")
    return setmetatable({ Part = part, _Attachments = {}, _Destroyed = false }, AttachmentBinder)
end

function AttachmentBinder:GetOrCreate(name: string, position: Vector3?, orientation: Vector3?)
    assert(not self._Destroyed, "Binder destroyed")
    local attachment = self._Attachments[name]
    if attachment and attachment.Parent == self.Part then return attachment end

    attachment = self.Part:FindFirstChild(name)
    if attachment and not attachment:IsA("Attachment") then
        error("An object with this name already exists and is not an Attachment")
    end
    if not attachment then
        attachment = Instance.new("Attachment")
        attachment.Name = name
        attachment.Parent = self.Part
        self._Attachments[name] = attachment
    end

    if position then attachment.Position = position end
    if orientation then attachment.Orientation = orientation end
    return attachment
end

function AttachmentBinder:Remove(name: string)
    local attachment = self._Attachments[name]
    if not attachment then return false end
    self._Attachments[name] = nil
    attachment:Destroy()
    return true
end

function AttachmentBinder:Destroy()
    if self._Destroyed then return end
    self._Destroyed = true
    for _, attachment in pairs(self._Attachments) do attachment:Destroy() end
    table.clear(self._Attachments)
end

return AttachmentBinder
