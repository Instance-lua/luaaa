--Strict
--Made by instance.


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.AdvancedRobloxLibrary.Core.State)

local Coins = State.new(0)

local connection = Coins:Subscribe(function(nextValue, previousValue, revision)
    print("Coins changed", previousValue, "->", nextValue, "revision", revision)
end, true)

Coins:Update(function(currentValue)
    return currentValue + 25
end)

connection:Disconnect()
Coins:Destroy()
