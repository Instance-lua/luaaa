--Strict
--Made by instance.


local Validator = {}

local function validateValue(value: any, schema: any, path: string, errors: {string})
    if value == nil then
        if schema.Required then
            table.insert(errors, path .. " is required")
        end
        return
    end

    local expectedType = schema.Type
    if expectedType and typeof(value) ~= expectedType then
        table.insert(errors, path .. " must be " .. expectedType)
        return
    end

    if typeof(value) == "number" then
        if schema.Min and value < schema.Min then
            table.insert(errors, path .. " is below minimum " .. tostring(schema.Min))
        end
        if schema.Max and value > schema.Max then
            table.insert(errors, path .. " is above maximum " .. tostring(schema.Max))
        end
    elseif typeof(value) == "string" then
        if schema.MinLength and #value < schema.MinLength then
            table.insert(errors, path .. " is shorter than minimum length")
        end
        if schema.MaxLength and #value > schema.MaxLength then
            table.insert(errors, path .. " exceeds maximum length")
        end
        if schema.Pattern and not string.match(value, schema.Pattern) then
            table.insert(errors, path .. " does not match required pattern")
        end
    elseif typeof(value) == "table" then
        if schema.Fields then
            for fieldName, fieldSchema in pairs(schema.Fields) do
                validateValue(value[fieldName], fieldSchema, path .. "." .. fieldName, errors)
            end
            if schema.AllowUnknownFields == false then
                for fieldName in pairs(value) do
                    if schema.Fields[fieldName] == nil then
                        table.insert(errors, path .. "." .. tostring(fieldName) .. " is not allowed")
                    end
                end
            end
        end
        if schema.Item then
            for index, item in ipairs(value) do
                validateValue(item, schema.Item, path .. "[" .. index .. "]", errors)
            end
        end
        if schema.MaxItems and #value > schema.MaxItems then
            table.insert(errors, path .. " contains too many items")
        end
    end

    if schema.Enum then
        local found = false
        for _, allowed in ipairs(schema.Enum) do
            if value == allowed then
                found = true
                break
            end
        end
        if not found then
            table.insert(errors, path .. " is not an allowed value")
        end
    end

    if schema.Custom then
        local ok, valid, message = pcall(schema.Custom, value)
        if not ok or not valid then
            table.insert(errors, path .. " failed custom validation: " .. tostring(message or valid))
        end
    end
end

function Validator.Validate(value: any, schema: any)
    assert(typeof(schema) == "table", "Schema must be a table")
    local errors = {}
    validateValue(value, schema, "$", errors)
    return #errors == 0, errors
end

return Validator
