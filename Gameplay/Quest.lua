--Strict
--Made by instance.


local Signal = require(script.Parent.Parent.Core.Signal)

local Quest = {}
Quest.__index = Quest

local STATUS = {
    Locked = "Locked",
    Available = "Available",
    Active = "Active",
    Completed = "Completed",
    Claimed = "Claimed",
}

function Quest.new(definition: any)
    assert(type(definition) == "table", "Quest definition required")
    assert(type(definition.Id) == "string", "Quest id required")
    assert(type(definition.Objectives) == "table", "Objectives required")

    local self = setmetatable({}, Quest)
    self.Id = definition.Id
    self.Name = definition.Name or definition.Id
    self.Reward = definition.Reward
    self.Status = definition.Locked and STATUS.Locked or STATUS.Available
    self.Objectives = {}
    self.Changed = Signal.new()
    self.Completed = Signal.new()
    self._Destroyed = false

    for index, objective in ipairs(definition.Objectives) do
        assert(type(objective.Id) == "string", "Objective id required")
        self.Objectives[objective.Id] = {
            Id = objective.Id,
            Description = objective.Description or objective.Id,
            Required = objective.Required or 1,
            Progress = 0,
            Index = index,
        }
    end
    return self
end

function Quest:Activate(): boolean
    if self.Status ~= STATUS.Available then
        return false
    end
    self.Status = STATUS.Active
    self.Changed:Fire("Status", self.Status)
    return true
end

function Quest:AddProgress(objectiveId: string, amount: number?): (boolean, string?)
    if self.Status ~= STATUS.Active then
        return false, "Quest is not active"
    end
    local objective = self.Objectives[objectiveId]
    if not objective then
        return false, "Unknown objective"
    end

    objective.Progress = math.min(objective.Required, objective.Progress + (amount or 1))
    self.Changed:Fire("Objective", objectiveId, objective.Progress, objective.Required)

    if self:IsComplete() then
        self.Status = STATUS.Completed
        self.Changed:Fire("Status", self.Status)
        self.Completed:Fire(self)
    end
    return true
end

function Quest:IsComplete(): boolean
    for _, objective in pairs(self.Objectives) do
        if objective.Progress < objective.Required then
            return false
        end
    end
    return true
end

function Quest:Claim(): (boolean, string?)
    if self.Status ~= STATUS.Completed then
        return false, "Quest is not completed"
    end
    self.Status = STATUS.Claimed
    self.Changed:Fire("Status", self.Status)
    return true
end

function Quest:GetSnapshot()
    local objectives = {}
    for id, objective in pairs(self.Objectives) do
        objectives[id] = {
            Progress = objective.Progress,
            Required = objective.Required,
        }
    end
    return {
        Id = self.Id,
        Name = self.Name,
        Status = self.Status,
        Objectives = objectives,
    }
end

function Quest:Destroy()
    if self._Destroyed then
        return
    end
    self._Destroyed = true
    self.Changed:Destroy()
    self.Completed:Destroy()
end

Quest.Statuses = STATUS
return Quest
