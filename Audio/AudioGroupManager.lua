--Strict
--Made by instance.


local SoundService = game:GetService("SoundService")

local AudioGroupManager = {}
AudioGroupManager.__index = AudioGroupManager

function AudioGroupManager.new(definitions: {[string]: number}?)
    local self = setmetatable({
        _Groups = {},
        _Owned = {},
        _Destroyed = false,
    }, AudioGroupManager)

    for name, volume in pairs(definitions or {}) do
        self:Create(name, volume)
    end
    return self
end

function AudioGroupManager:Create(name: string, volume: number?)
    assert(not self._Destroyed, "AudioGroupManager has been destroyed")
    assert(type(name) == "string" and #name > 0, "Group name required")

    local group = self._Groups[name]
    if group and group.Parent then
        group.Volume = math.clamp(volume or group.Volume, 0, 10)
        return group
    end

    group = Instance.new("SoundGroup")
    group.Name = name
    group.Volume = math.clamp(volume or 1, 0, 10)
    group.Parent = SoundService
    self._Groups[name] = group
    self._Owned[group] = true
    return group
end

function AudioGroupManager:Get(name: string): SoundGroup?
    return self._Groups[name]
end

function AudioGroupManager:SetVolume(name: string, volume: number): boolean
    local group = self._Groups[name]
    if not group then
        return false
    end
    group.Volume = math.clamp(volume, 0, 10)
    return true
end

function AudioGroupManager:Assign(sound: Sound, groupName: string): boolean
    local group = self._Groups[groupName]
    if not group then
        return false
    end
    sound.SoundGroup = group
    return true
end

function AudioGroupManager:Destroy()
    if self._Destroyed then
        return
    end
    self._Destroyed = true
    for group in pairs(self._Owned) do
        group:Destroy()
    end
    table.clear(self._Owned)
    table.clear(self._Groups)
end

return AudioGroupManager
