--Strict
--Made by instance.


local BinaryHeap = require(script.Parent.BinaryHeap)

local Graph = {}
Graph.__index = Graph

function Graph.new()
    return setmetatable({ _Adjacency = {}, _EdgeCount = 0 }, Graph)
end

function Graph:AddVertex(vertex: any)
    if self._Adjacency[vertex] then
        return false
    end
    self._Adjacency[vertex] = {}
    return true
end

function Graph:AddEdge(from: any, to: any, weight: number?, bidirectional: boolean?)
    assert(type(weight or 1) == "number" and (weight or 1) >= 0, "Edge weight must be non-negative")
    self:AddVertex(from)
    self:AddVertex(to)

    local edgeWeight = weight or 1
    if self._Adjacency[from][to] == nil then
        self._EdgeCount += 1
    end
    self._Adjacency[from][to] = edgeWeight

    if bidirectional then
        if self._Adjacency[to][from] == nil then
            self._EdgeCount += 1
        end
        self._Adjacency[to][from] = edgeWeight
    end
end

function Graph:RemoveVertex(vertex: any): boolean
    if not self._Adjacency[vertex] then
        return false
    end
    self._Adjacency[vertex] = nil
    for _, neighbors in pairs(self._Adjacency) do
        if neighbors[vertex] ~= nil then
            neighbors[vertex] = nil
            self._EdgeCount -= 1
        end
    end
    return true
end

function Graph:GetNeighbors(vertex: any)
    local neighbors = {}
    for neighbor, weight in pairs(self._Adjacency[vertex] or {}) do
        table.insert(neighbors, { Vertex = neighbor, Weight = weight })
    end
    return neighbors
end

function Graph:BreadthFirstSearch(startVertex: any, goalVertex: any)
    if not self._Adjacency[startVertex] then
        return nil
    end
    local queue = { startVertex }
    local head = 1
    local previous = { [startVertex] = false }

    while head <= #queue do
        local current = queue[head]
        head += 1
        if current == goalVertex then
            local path = {}
            while current do
                table.insert(path, 1, current)
                current = previous[current]
            end
            return path
        end
        for neighbor in pairs(self._Adjacency[current]) do
            if previous[neighbor] == nil then
                previous[neighbor] = current
                table.insert(queue, neighbor)
            end
        end
    end
    return nil
end

function Graph:Dijkstra(startVertex: any, goalVertex: any)
    if not self._Adjacency[startVertex] or not self._Adjacency[goalVertex] then
        return nil, math.huge
    end

    local distances = { [startVertex] = 0 }
    local previous = {}
    local visited = {}
    local heap = BinaryHeap.new(function(left, right)
        return left.Distance < right.Distance
    end)
    heap:Push({ Vertex = startVertex, Distance = 0 })

    while not heap:IsEmpty() do
        local entry = heap:Pop()
        local current = entry.Vertex
        if not visited[current] then
            visited[current] = true
            if current == goalVertex then
                local path = {}
                local cursor = goalVertex
                while cursor do
                    table.insert(path, 1, cursor)
                    cursor = previous[cursor]
                end
                return path, entry.Distance
            end

            for neighbor, weight in pairs(self._Adjacency[current]) do
                local candidate = entry.Distance + weight
                if distances[neighbor] == nil or candidate < distances[neighbor] then
                    distances[neighbor] = candidate
                    previous[neighbor] = current
                    heap:Push({ Vertex = neighbor, Distance = candidate })
                end
            end
        end
    end

    return nil, math.huge
end

function Graph:GetCounts()
    local vertexCount = 0
    for _ in pairs(self._Adjacency) do
        vertexCount += 1
    end
    return vertexCount, self._EdgeCount
end

return Graph
