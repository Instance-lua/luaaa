--Strict
--Made by instance.


local ColorUtil = {}

function ColorUtil.Lerp(left: Color3, right: Color3, alpha: number): Color3
    return left:Lerp(right, math.clamp(alpha, 0, 1))
end

function ColorUtil.FromHex(hex: string): Color3?
    hex = string.gsub(hex, "^#", "")
    if #hex ~= 6 or not string.match(hex, "^%x%x%x%x%x%x$") then return nil end
    local red = tonumber(string.sub(hex, 1, 2), 16)
    local green = tonumber(string.sub(hex, 3, 4), 16)
    local blue = tonumber(string.sub(hex, 5, 6), 16)
    return Color3.fromRGB(red, green, blue)
end

function ColorUtil.ToHex(color: Color3): string
    local red = math.floor(color.R * 255 + 0.5)
    local green = math.floor(color.G * 255 + 0.5)
    local blue = math.floor(color.B * 255 + 0.5)
    return string.format("#%02X%02X%02X", red, green, blue)
end

function ColorUtil.ContrastText(color: Color3): Color3
    local luminance = 0.2126 * color.R + 0.7152 * color.G + 0.0722 * color.B
    return luminance > 0.55 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
end

return ColorUtil
