--Strict
--Made by instance.


local Serializer = {}

local function encodeValue(value: any, visited: {[table]: boolean}, depth: number, maxDepth: number): any
    assert(depth <= maxDepth, "Maximum serialization depth exceeded")
    local valueType = typeof(value)

    if valueType == "nil" or valueType == "boolean" or valueType == "number" or valueType == "string" then
        assert(valueType ~= "number" or (value == value and math.abs(value) < math.huge), "Non-finite number")
        return value
    end

    assert(valueType == "table", "Unsupported value type: " .. valueType)
    assert(not visited[value], "Cyclic tables cannot be serialized")
    visited[value] = true

    local encoded = {}
    local keys = {}
    for key in pairs(value) do
        local keyType = typeof(key)
        assert(keyType == "string" or keyType == "number" or keyType == "boolean", "Unsupported table key")
        table.insert(keys, key)
    end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)

    for _, key in ipairs(keys) do
        encoded[#encoded + 1] = {
            Key = encodeValue(key, visited, depth + 1, maxDepth),
            Value = encodeValue(value[key], visited, depth + 1, maxDepth),
        }
    end

    visited[value] = nil
    return { __Type = "Table", Entries = encoded }
end

function Serializer.Encode(value: any, maxDepth: number?)
    return encodeValue(value, {}, 0, maxDepth or 32)
end

local function decodeValue(value: any, depth: number, maxDepth: number): any
    assert(depth <= maxDepth, "Maximum deserialization depth exceeded")
    if typeof(value) ~= "table" then
        return value
    end
    assert(value.__Type == "Table" and typeof(value.Entries) == "table", "Invalid encoded table")
    local decoded = {}
    for _, entry in ipairs(value.Entries) do
        assert(typeof(entry) == "table" and entry.Key ~= nil, "Invalid table entry")
        decoded[decodeValue(entry.Key, depth + 1, maxDepth)] =
            decodeValue(entry.Value, depth + 1, maxDepth)
    end
    return decoded
end

function Serializer.Decode(value: any, maxDepth: number?)
    return decodeValue(value, 0, maxDepth or 32)
end

return Serializer
