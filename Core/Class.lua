--Strict
--Made by instance.


local Class = {}
Class.__index = Class

export type ClassDefinition = {
    Name: string,
    Super: any?,
    Constructor: ((any, ...any) -> ())?,
}

function Class.Create(definition: ClassDefinition)
    assert(type(definition) == "table", "Class definition must be a table")
    assert(type(definition.Name) == "string", "Class name is required")

    local parent = definition.Super
    local class = {}
    class.__index = class
    class.ClassName = definition.Name
    class.Super = parent

    if parent then
        setmetatable(class, { __index = parent })
    end

    function class.new(...)
        local self = setmetatable({}, class)
        self.Destroyed = false

        if definition.Constructor then
            definition.Constructor(self, ...)
        elseif parent and parent.Constructor then
            parent.Constructor(self, ...)
        end

        return self
    end

    function class:IsA(className: string): boolean
        local current = getmetatable(self)
        while current do
            if current.ClassName == className then
                return true
            end
            current = current.Super
        end
        return false
    end

    function class:AssertAlive()
        assert(not self.Destroyed, self.ClassName .. " has been destroyed")
    end

    function class:Destroy()
        if self.Destroyed then
            return
        end
        self.Destroyed = true
    end

    return class
end

return Class
