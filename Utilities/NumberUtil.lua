--Strict
--Made by instance.


local NumberUtil = {}

function NumberUtil.Clamp(value: number, minimum: number, maximum: number): number
    assert(minimum <= maximum, "Minimum must not exceed maximum")
    return math.clamp(value, minimum, maximum)
end

function NumberUtil.Lerp(startValue: number, endValue: number, alpha: number): number
    return startValue + (endValue - startValue) * alpha
end

function NumberUtil.Remap(value: number, inputMinimum: number, inputMaximum: number, outputMinimum: number, outputMaximum: number): number
    assert(inputMaximum ~= inputMinimum, "Input range cannot be zero")
    local alpha = (value - inputMinimum) / (inputMaximum - inputMinimum)
    return NumberUtil.Lerp(outputMinimum, outputMaximum, alpha)
end

function NumberUtil.Round(value: number, decimals: number?): number
    local factor = 10 ^ (decimals or 0)
    return math.floor(value * factor + 0.5) / factor
end

function NumberUtil.IsFinite(value: number): boolean
    return value == value and math.abs(value) < math.huge
end

function NumberUtil.FormatCompact(value: number): string
    local suffixes = { "", "K", "M", "B", "T" }
    local index = 1
    while math.abs(value) >= 1000 and index < #suffixes do
        value /= 1000
        index += 1
    end
    return tostring(NumberUtil.Round(value, 1)) .. suffixes[index]
end

function NumberUtil.Sign(value: number): number
    if value > 0 then return 1 end
    if value < 0 then return -1 end
    return 0
end

return NumberUtil
