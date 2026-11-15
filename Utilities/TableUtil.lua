--Strict
--Made by instance.


local TableUtil = {}

function TableUtil.DeepCopy(source: any, seen: {[table]: table}?)
    if typeof(source) ~= "table" then return source end
    seen = seen or {}
    if seen[source] then return seen[source] end
    local copy = {}
    seen[source] = copy
    for key, value in pairs(source) do
        copy[TableUtil.DeepCopy(key, seen)] = TableUtil.DeepCopy(value, seen)
    end
    return setmetatable(copy, getmetatable(source))
end

function TableUtil.DeepEqual(left: any, right: any, seen: {[table]: table}?)
    if left == right then return true end
    if typeof(left) ~= "table" or typeof(right) ~= "table" then return false end
    seen = seen or {}
    if seen[left] == right then return true end
    seen[left] = right
    for key, value in pairs(left) do
        if not TableUtil.DeepEqual(value, right[key], seen) then return false end
    end
    for key in pairs(right) do
        if left[key] == nil then return false end
    end
    return true
end

function TableUtil.Merge(target: {[any]: any}, source: {[any]: any}, overwrite: boolean?)
    for key, value in pairs(source) do
        if typeof(value) == "table" and typeof(target[key]) == "table" then
            TableUtil.Merge(target[key], value, overwrite)
        elseif overwrite or target[key] == nil then
            target[key] = TableUtil.DeepCopy(value)
        end
    end
    return target
end

function TableUtil.Keys(source: {[any]: any})
    local result = {}
    for key in pairs(source) do table.insert(result, key) end
    return result
end

function TableUtil.Values(source: {[any]: any})
    local result = {}
    for _, value in pairs(source) do table.insert(result, value) end
    return result
end

function TableUtil.Filter(source: {any}, predicate: (any, number) -> boolean)
    local result = {}
    for index, value in ipairs(source) do
        if predicate(value, index) then table.insert(result, value) end
    end
    return result
end

function TableUtil.Map(source: {any}, transform: (any, number) -> any)
    local result = {}
    for index, value in ipairs(source) do result[index] = transform(value, index) end
    return result
end

function TableUtil.Reduce(source: {any}, reducer: (any, any, number) -> any, initial: any)
    local result = initial
    for index, value in ipairs(source) do result = reducer(result, value, index) end
    return result
end

return TableUtil
