--Strict
--Made by instance.


local Signal = require(script.Parent.Parent.Core.Signal)

local AchievementManager = {}
AchievementManager.__index = AchievementManager

function AchievementManager.new(definitions: {[string]: any})
    local self = setmetatable({}, AchievementManager)
    self._Definitions = definitions
    self._Unlocked = {}
    self.Unlocked = Signal.new()
    return self
end

function AchievementManager:Unlock(player: Player, achievementId: string): (boolean, string?)
    local definition = self._Definitions[achievementId]
    if not definition then
        return false, "Unknown achievement"
    end

    local userId = player.UserId
    self._Unlocked[userId] = self._Unlocked[userId] or {}
    if self._Unlocked[userId][achievementId] then
        return false, "Already unlocked"
    end

    self._Unlocked[userId][achievementId] = os.time()
    self.Unlocked:Fire(player, achievementId, definition)
    return true
end

function AchievementManager:Has(player: Player, achievementId: string): boolean
    return self._Unlocked[player.UserId] ~= nil
        and self._Unlocked[player.UserId][achievementId] ~= nil
end

function AchievementManager:GetUnlocked(player: Player)
    local source = self._Unlocked[player.UserId] or {}
    local copy = {}
    for id, timestamp in pairs(source) do
        copy[id] = timestamp
    end
    return copy
end

function AchievementManager:RemovePlayer(player: Player)
    self._Unlocked[player.UserId] = nil
end

function AchievementManager:Destroy()
    self.Unlocked:Destroy()
    table.clear(self._Unlocked)
end

return AchievementManager
