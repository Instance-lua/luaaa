--Strict
--Made by instance.


local Trie = {}
Trie.__index = Trie

local function createNode()
    return { Children = {}, IsWord = false, Value = nil }
end

function Trie.new()
    return setmetatable({
        _Root = createNode(),
        _WordCount = 0,
    }, Trie)
end

function Trie:Insert(word: string, value: any?)
    assert(type(word) == "string" and #word > 0, "Word must be a non-empty string")
    local node = self._Root
    for index = 1, #word do
        local character = string.sub(word, index, index)
        if not node.Children[character] then
            node.Children[character] = createNode()
        end
        node = node.Children[character]
    end

    if not node.IsWord then
        self._WordCount += 1
    end
    node.IsWord = true
    node.Value = value
end

function Trie:Find(word: string)
    local node = self._Root
    for index = 1, #word do
        node = node.Children[string.sub(word, index, index)]
        if not node then
            return nil
        end
    end
    if node.IsWord then
        return node.Value == nil and true or node.Value
    end
    return nil
end

function Trie:HasPrefix(prefix: string): boolean
    local node = self._Root
    for index = 1, #prefix do
        node = node.Children[string.sub(prefix, index, index)]
        if not node then
            return false
        end
    end
    return true
end

function Trie:Remove(word: string): boolean
    local function remove(node, index)
        if index > #word then
            if not node.IsWord then
                return false, false
            end
            node.IsWord = false
            node.Value = nil
            return true, next(node.Children) == nil
        end

        local character = string.sub(word, index, index)
        local child = node.Children[character]
        if not child then
            return false, false
        end

        local removed, shouldPrune = remove(child, index + 1)
        if shouldPrune then
            node.Children[character] = nil
        end
        return removed, not node.IsWord and next(node.Children) == nil
    end

    local removed = remove(self._Root, 1)
    if removed then
        self._WordCount -= 1
    end
    return removed
end

function Trie:Complete(prefix: string, limit: number?)
    local node = self._Root
    for index = 1, #prefix do
        node = node.Children[string.sub(prefix, index, index)]
        if not node then
            return {}
        end
    end

    local results = {}
    local function visit(current, path)
        if limit and #results >= limit then
            return
        end
        if current.IsWord then
            table.insert(results, { Word = path, Value = current.Value })
        end
        local keys = {}
        for character in pairs(current.Children) do
            table.insert(keys, character)
        end
        table.sort(keys)
        for _, character in ipairs(keys) do
            visit(current.Children[character], path .. character)
            if limit and #results >= limit then
                return
            end
        end
    end

    visit(node, prefix)
    return results
end

function Trie:Count(): number
    return self._WordCount
end

return Trie
