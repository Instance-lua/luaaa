--Strict
--Made by instance.


local Signal = require(script.Parent.Parent.Core.Signal)
local Maid = require(script.Parent.Parent.Core.Maid)

local CharacterTracker = {}
CharacterTracker.__index = CharacterTracker

function CharacterTracker.new(player: Player)
    assert(player and player:IsA("Player"), "CharacterTracker requires a Player")

    local self = setmetatable({}, CharacterTracker)
    self.Player = player
    self.Character = nil
    self.Humanoid = nil
    self.RootPart = nil
    self.CharacterAdded = Signal.new()
    self.CharacterRemoving = Signal.new()
    self.CharacterReady = Signal.new()
    self._Maid = Maid.new()
    self._CharacterMaid = Maid.new()
    self.Destroyed = false
    self._CharacterGeneration = 0

    self._Maid:Give(player.CharacterAdded:Connect(function(character)
        self:_BindCharacter(character)
    end))

    self._Maid:Give(player.CharacterRemoving:Connect(function(character)
        if self.Character ~= character then
            return
        end

        self.CharacterRemoving:Fire(character)
        self:_ClearCharacter()
    end))

    if player.Character then
        self:_BindCharacter(player.Character)
    end

    return self
end

function CharacterTracker:_ClearCharacter()
    self._CharacterGeneration += 1
    self._CharacterMaid:DoCleaning()
    self.Character = nil
    self.Humanoid = nil
    self.RootPart = nil
end

function CharacterTracker:_RefreshCharacterParts()
    local character = self.Character
    if not character or self.Destroyed then
        return
    end

    local previousHumanoid = self.Humanoid
    local previousRootPart = self.RootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoid and not humanoid:IsA("Humanoid") then
        humanoid = nil
    end

    if rootPart and not rootPart:IsA("BasePart") then
        rootPart = nil
    end

    self.Humanoid = humanoid
    self.RootPart = rootPart

    if humanoid and rootPart and (previousHumanoid ~= humanoid or previousRootPart ~= rootPart) then
        self.CharacterReady:Fire(character, humanoid, rootPart)
    end
end

function CharacterTracker:_BindCharacter(character: Model)
    if self.Destroyed or self.Character == character then
        return
    end

    self:_ClearCharacter()
    self.Character = character
    self._CharacterGeneration += 1
    local generation = self._CharacterGeneration

    self._CharacterMaid:Give(character.ChildAdded:Connect(function(child)
        if self.Character ~= character or generation ~= self._CharacterGeneration then
            return
        end

        if child:IsA("Humanoid") or child.Name == "HumanoidRootPart" then
            self:_RefreshCharacterParts()
        end
    end))

    self._CharacterMaid:Give(character.ChildRemoved:Connect(function(child)
        if self.Character ~= character or generation ~= self._CharacterGeneration then
            return
        end

        if child == self.Humanoid or child == self.RootPart then
            self:_RefreshCharacterParts()
        end
    end))

    self._CharacterMaid:Give(character.AncestryChanged:Connect(function(_, parent)
        if parent == nil and self.Character == character then
            self.CharacterRemoving:Fire(character)
            self:_ClearCharacter()
        end
    end))

    self:_RefreshCharacterParts()
    self.CharacterAdded:Fire(character, self.Humanoid, self.RootPart)
end

function CharacterTracker:GetCharacter(): Model?
    return self.Character
end

function CharacterTracker:GetHumanoid(): Humanoid?
    return self.Humanoid
end

function CharacterTracker:GetRootPart(): BasePart?
    return self.RootPart
end

function CharacterTracker:IsReady(): boolean
    return self.Character ~= nil and self.Humanoid ~= nil and self.RootPart ~= nil
end

function CharacterTracker:WaitForCharacter(timeout: number?): (Model?, Humanoid?, BasePart?)
    assert(timeout == nil or timeout >= 0, "Timeout cannot be negative")

    local deadline = timeout and os.clock() + timeout

    repeat
        if self.Destroyed then
            return nil
        end

        if self:IsReady() then
            return self.Character, self.Humanoid, self.RootPart
        end

        if deadline and os.clock() >= deadline then
            return nil
        end

        task.wait()
    until false
end

function CharacterTracker:WaitForCharacterModel(timeout: number?): Model?
    assert(timeout == nil or timeout >= 0, "Timeout cannot be negative")

    local deadline = timeout and os.clock() + timeout

    repeat
        if self.Destroyed then
            return nil
        end

        if self.Character then
            return self.Character
        end

        if deadline and os.clock() >= deadline then
            return nil
        end

        task.wait()
    until false
end

function CharacterTracker:Destroy()
    if self.Destroyed then
        return
    end

    self.Destroyed = true
    self:_ClearCharacter()
    self._Maid:Destroy()
    self._CharacterMaid:Destroy()
    self.CharacterAdded:Destroy()
    self.CharacterRemoving:Destroy()
    self.CharacterReady:Destroy()
    self.Player = nil
end

return CharacterTracker
