--Strict
--Made by instance.


local Workspace = game:GetService("Workspace")

local SpatialQuery = {}
SpatialQuery.__index = SpatialQuery

function SpatialQuery.new(options: any?)
    options = options or {}
    local overlap = OverlapParams.new()
    overlap.FilterType = options.FilterType or Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = options.FilterDescendantsInstances or {}

    local raycast = RaycastParams.new()
    raycast.FilterType = options.FilterType or Enum.RaycastFilterType.Exclude
    raycast.FilterDescendantsInstances = options.FilterDescendantsInstances or {}
    raycast.IgnoreWater = options.IgnoreWater == true

    return setmetatable({
        OverlapParams = overlap,
        RaycastParams = raycast,
        Workspace = options.Workspace or Workspace,
    }, SpatialQuery)
end

function SpatialQuery:SetFilter(instances: {Instance}, filterType: Enum.RaycastFilterType?)
    self.OverlapParams.FilterDescendantsInstances = instances
    self.RaycastParams.FilterDescendantsInstances = instances
    if filterType then
        self.OverlapParams.FilterType = filterType
        self.RaycastParams.FilterType = filterType
    end
end

function SpatialQuery:GetPartsInBox(cframe: CFrame, size: Vector3, maximumParts: number?)
    return self.Workspace:GetPartBoundsInBox(cframe, size, self.OverlapParams)
end

function SpatialQuery:GetPartsInRadius(position: Vector3, radius: number, maximumParts: number?)
    assert(radius > 0, "Radius must be positive")
    return self.Workspace:GetPartBoundsInRadius(position, radius, self.OverlapParams)
end

function SpatialQuery:Raycast(origin: Vector3, direction: Vector3)
    assert(direction.Magnitude > 0, "Direction must not be zero")
    return self.Workspace:Raycast(origin, direction, self.RaycastParams)
end

function SpatialQuery:FindNearest(position: Vector3, radius: number, predicate: ((BasePart) -> boolean)?)
    local nearest = nil
    local nearestDistance = radius
    for _, part in ipairs(self:GetPartsInRadius(position, radius)) do
        if part:IsA("BasePart") and (predicate == nil or predicate(part)) then
            local distance = (part.Position - position).Magnitude
            if distance < nearestDistance then
                nearest = part
                nearestDistance = distance
            end
        end
    end
    return nearest, nearestDistance
end

return SpatialQuery
