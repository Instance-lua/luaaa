--Strict
--Made by instance.


local InputSanitizer = {}

function InputSanitizer.Text(value: any, maximumLength: number?): (string?, string?)
    if typeof(value) ~= "string" then return nil, "Expected text" end
    local maximum = maximumLength or 200
    if #value > maximum then return nil, "Text is too long" end
    local cleaned = string.gsub(value, "[%z\1-\8\11\12\14-\31]", "")
    cleaned = string.gsub(cleaned, "^%s*(.-)%s*$", "%1")
    return cleaned
end

function InputSanitizer.Integer(value: any, minimum: number, maximum: number): (number?, string?)
    if typeof(value) ~= "number" or value ~= value or math.abs(value) == math.huge then
        return nil, "Expected finite number"
    end
    if value % 1 ~= 0 then return nil, "Expected integer" end
    if value < minimum or value > maximum then return nil, "Number outside permitted range" end
    return value
end

function InputSanitizer.Identifier(value: any, maximumLength: number?): (string?, string?)
    local cleaned, reason = InputSanitizer.Text(value, maximumLength or 48)
    if not cleaned then return nil, reason end
    if not string.match(cleaned, "^[%w_%-]+$") then return nil, "Invalid identifier" end
    return cleaned
end

return InputSanitizer
