--Strict
--Made by instance.


local StringUtil = {}

function StringUtil.Trim(value: string): string
    return string.match(value, "^%s*(.-)%s*$") or ""
end

function StringUtil.Split(value: string, separator: string)
    assert(separator ~= "", "Separator cannot be empty")
    local result = {}
    local startIndex = 1
    while true do
        local first, last = string.find(value, separator, startIndex, true)
        if not first then
            table.insert(result, string.sub(value, startIndex))
            break
        end
        table.insert(result, string.sub(value, startIndex, first - 1))
        startIndex = last + 1
    end
    return result
end

function StringUtil.StartsWith(value: string, prefix: string): boolean
    return string.sub(value, 1, #prefix) == prefix
end

function StringUtil.EndsWith(value: string, suffix: string): boolean
    return suffix == "" or string.sub(value, -#suffix) == suffix
end

function StringUtil.CamelToWords(value: string): string
    local spaced = string.gsub(value, "(%l)(%u)", "%1 %2")
    return string.gsub(spaced, "_", " ")
end

function StringUtil.Truncate(value: string, maximum: number, suffix: string?): string
    assert(maximum >= 0, "Maximum length cannot be negative")
    if #value <= maximum then return value end
    suffix = suffix or "..."
    if maximum <= #suffix then return string.sub(suffix, 1, maximum) end
    return string.sub(value, 1, maximum - #suffix) .. suffix
end

function StringUtil.IsBlank(value: string): boolean
    return StringUtil.Trim(value) == ""
end

return StringUtil
