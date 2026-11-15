--Strict
--Made by instance.


local Players = game:GetService("Players")
local Signal = require(script.Parent.Parent.Core.Signal)

local PlayerRegistry = {}
PlayerRegistry.__index = PlayerRegistry

function PlayerRegistry.new()
    local self = setmetatable({
        _ByUserId = {},
        _AddedConnection = nil,
        _RemovingConnection = nil,
        PlayerAdded = Signal.new(),
        PlayerRemoving = Signal.new(),
        _Destroyed = false,
    }, PlayerRegistry)

    self._AddedConnection = Players.PlayerAdded:Connect(function(player)
        self._ByUserId[player.UserId] = player
        self.PlayerAdded:Fire(player)
    end)
    self._RemovingConnection = Players.PlayerRemoving:Connect(function(player)
        self.PlayerRemoving:Fire(player)
        self._ByUserId[player.UserId] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do self._ByUserId[player.UserId] = player end
    return self
end

function PlayerRegistry:GetByUserId(userId: number): Player?
    return self._ByUserId[userId]
end

function PlayerRegistry:GetAll()
    local result = {}
    for _, player in pairs(self._ByUserId) do table.insert(result, player) end
    table.sort(result, function(left, right) return left.UserId < right.UserId end)
    return result
end

function PlayerRegistry:Count(): number
    local count = 0
    for _ in pairs(self._ByUserId) do count += 1 end
    return count
end

function PlayerRegistry:Destroy()
    if self._Destroyed then return end
    self._Destroyed = true
    self._AddedConnection:Disconnect()
    self._RemovingConnection:Disconnect()
    self.PlayerAdded:Destroy()
    self.PlayerRemoving:Destroy()
    table.clear(self._ByUserId)
end

return PlayerRegistry
