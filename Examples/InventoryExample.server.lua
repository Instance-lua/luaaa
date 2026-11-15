--Strict
--Made by instance.


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Library = ReplicatedStorage:WaitForChild("AdvancedRobloxLibrary")
local Inventory = require(Library.Gameplay.Inventory)
local Maid = require(Library.Core.Maid)

local inventories = {}
local playerMaids = {}

local function onPlayerAdded(player: Player)
    local maid = Maid.new()
    playerMaids[player] = maid

    local inventory = Inventory.new({
        MaxSlots = 30,
        MaxStack = 99,
    })
    inventories[player] = inventory
    maid:Give(inventory)

    maid:Give(player.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            inventories[player] = nil
            playerMaids[player] = nil
            maid:Destroy()
        end
    end))

    inventory.Changed:Connect(function(action, itemId, amount, revision)
        print(player.Name, action, itemId, amount, revision)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    local maid = playerMaids[player]
    if maid then
        maid:Destroy()
    end
    inventories[player] = nil
    playerMaids[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end
