--Strict
--Made by instance.


local Signal = require(script.Parent.Parent.Core.Signal)
local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(initialState: string, definitions: {[string]: any})
    assert(definitions[initialState], "Initial state is not defined")
    return setmetatable({
        CurrentState = initialState,
        Definitions = definitions,
        Changed = Signal.new(),
        Transitioning = false,
        Destroyed = false,
    }, StateMachine)
end

function StateMachine:CanTransition(nextState: string, context: any?): (boolean, string?)
    local current = self.Definitions[self.CurrentState]
    local target = self.Definitions[nextState]
    if not target then return false, "Unknown target state" end
    if self.Transitioning then return false, "Transition already in progress" end
    if current.Transitions and not current.Transitions[nextState] then
        return false, "Transition is not permitted"
    end
    if target.CanEnter then
        local ok, allowed, reason = pcall(target.CanEnter, context, self.CurrentState)
        if not ok or not allowed then return false, tostring(reason or allowed) end
    end
    return true
end

function StateMachine:Transition(nextState: string, context: any?): (boolean, string?)
    assert(not self.Destroyed, "StateMachine destroyed")
    local allowed, reason = self:CanTransition(nextState, context)
    if not allowed then return false, reason end
    if nextState == self.CurrentState then return true end

    self.Transitioning = true
    local previousState = self.CurrentState
    local previous = self.Definitions[previousState]
    local target = self.Definitions[nextState]

    local ok, message = xpcall(function()
        if previous.Exit then previous.Exit(context, nextState) end
        self.CurrentState = nextState
        if target.Enter then target.Enter(context, previousState) end
    end, debug.traceback)

    self.Transitioning = false
    if not ok then
        self.CurrentState = previousState
        return false, message
    end
    self.Changed:Fire(nextState, previousState, context)
    return true
end

function StateMachine:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self.Changed:Destroy()
end

return StateMachine
