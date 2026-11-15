--Strict
--Made by instance.


local EnumUtil = {}

function EnumUtil.GetNames(enumType: Enum)
    local result = {}
    for _, item in ipairs(enumType:GetEnumItems()) do table.insert(result, item.Name) end
    table.sort(result)
    return result
end

function EnumUtil.TryParse(enumType: Enum, name: string)
    local ok, result = pcall(function() return enumType[name] end)
    if not ok then return nil end
    return result
end

function EnumUtil.IsValid(enumType: Enum, item: EnumItem): boolean
    for _, candidate in ipairs(enumType:GetEnumItems()) do
        if candidate == item then return true end
    end
    return false
end

return EnumUtil
