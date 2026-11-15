--Strict
--Made by instance.


local Signal = require(script.Parent.Parent.Core.Signal)

local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(options: any?)
    options = options or {}
    return setmetatable({
        _Items = {},
        _MaxSlots = options.MaxSlots or 100,
        _MaxStack = options.MaxStack or 999,
        _Revision = 0,
        Changed = Signal.new(),
        Destroyed = false,
    }, Inventory)
end

function Inventory:_Commit(action: string, itemId: string, amount: number)
    self._Revision += 1
    self.Changed:Fire(action, itemId, amount, self._Revision)
end

function Inventory:Get(itemId: string): number
    return self._Items[itemId] or 0
end

function Inventory:GetAll()
    local copy = {}
    for itemId, amount in pairs(self._Items) do
        copy[itemId] = amount
    end
    return copy
end

function Inventory:GetSlotCount(): number
    local count = 0
    for _ in pairs(self._Items) do
        count += 1
    end
    return count
end

function Inventory:Add(itemId: string, amount: number?): (boolean, string?)
    assert(not self.Destroyed, "Inventory has been destroyed")
    amount = amount or 1
    assert(type(itemId) == "string" and #itemId > 0, "Invalid item id")
    assert(type(amount) == "number" and amount > 0 and amount % 1 == 0, "Amount must be a positive integer")

    local current = self:Get(itemId)
    if current + amount > self._MaxStack then
        return false, "Stack limit exceeded"
    end
    if current == 0 and self:GetSlotCount() >= self._MaxSlots then
        return false, "Inventory is full"
    end

    self._Items[itemId] = current + amount
    self:_Commit("Added", itemId, amount)
    return true
end

function Inventory:Remove(itemId: string, amount: number?): (boolean, string?)
    assert(not self.Destroyed, "Inventory has been destroyed")
    amount = amount or 1
    assert(type(amount) == "number" and amount > 0 and amount % 1 == 0, "Amount must be a positive integer")

    local current = self:Get(itemId)
    if current < amount then
        return false, "Insufficient quantity"
    end

    local remaining = current - amount
    if remaining == 0 then
        self._Items[itemId] = nil
    else
        self._Items[itemId] = remaining
    end
    self:_Commit("Removed", itemId, amount)
    return true
end

function Inventory:Has(itemId: string, amount: number?): boolean
    return self:Get(itemId) >= (amount or 1)
end

function Inventory:Clear()
    local previous = self._Items
    self._Items = {}
    for itemId, amount in pairs(previous) do
        self:_Commit("Removed", itemId, amount)
    end
end

function Inventory:GetRevision(): number
    return self._Revision
end

function Inventory:Destroy()
    if self.Destroyed then
        return
    end
    self.Destroyed = true
    self.Changed:Destroy()
    table.clear(self._Items)
end

return Inventory
