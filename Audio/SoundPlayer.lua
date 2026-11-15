--Strict
--Made by instance.


local SoundService = game:GetService("SoundService")
local SoundPlayer = {}
SoundPlayer.__index = SoundPlayer

function SoundPlayer.new(parent: Instance?)
    return setmetatable({ Parent = parent or SoundService, _Active = {}, _Destroyed = false }, SoundPlayer)
end

function SoundPlayer:Play(soundId: string, options: any?)
    assert(not self._Destroyed, "SoundPlayer destroyed")
    assert(type(soundId) == "string" and soundId ~= "", "Sound id required")
    options = options or {}

    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = math.clamp(options.Volume or 1, 0, 10)
    sound.PlaybackSpeed = math.clamp(options.PlaybackSpeed or 1, 0.05, 20)
    sound.Looped = options.Looped == true
    sound.Parent = options.Parent or self.Parent
    if options.Group then sound.SoundGroup = options.Group end

    self._Active[sound] = true
    if not sound.Looped then
        sound.Ended:Once(function()
            self._Active[sound] = nil
            sound:Destroy()
        end)
    end
    sound:Play()
    return sound
end

function SoundPlayer:StopAll()
    for sound in pairs(self._Active) do
        sound:Stop()
        sound:Destroy()
        self._Active[sound] = nil
    end
end

function SoundPlayer:Destroy()
    if self._Destroyed then return end
    self._Destroyed = true
    self:StopAll()
    self.Parent = nil
end

return SoundPlayer
