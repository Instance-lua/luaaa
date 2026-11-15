--Strict
--Made by instance.


local Logger = {}
Logger.__index = Logger

local LEVELS = {
    Trace = 1,
    Debug = 2,
    Info = 3,
    Warn = 4,
    Error = 5,
    Fatal = 6,
}

function Logger.new(options: any?)
    options = options or {}
    return setmetatable({
        MinimumLevel = options.MinimumLevel or LEVELS.Info,
        Category = options.Category or "Application",
        Sink = options.Sink,
        IncludeTimestamp = options.IncludeTimestamp ~= false,
        _History = {},
        _HistoryLimit = options.HistoryLimit or 200,
    }, Logger)
end

function Logger:_Write(levelName: string, ...)
    local level = LEVELS[levelName]
    if level < self.MinimumLevel then
        return
    end

    local parts = {}
    for index, value in ipairs(table.pack(...)) do
        parts[index] = tostring(value)
    end

    local record = {
        Level = levelName,
        Category = self.Category,
        Message = table.concat(parts, " "),
        Timestamp = os.time(),
    }

    table.insert(self._History, record)
    if #self._History > self._HistoryLimit then
        table.remove(self._History, 1)
    end

    if self.Sink then
        local ok, message = pcall(self.Sink, record)
        if not ok then
            warn("[Logger] Sink failed: " .. tostring(message))
        end
        return
    end

    local prefix = "[" .. self.Category .. "][" .. levelName .. "]"
    local output = prefix .. " " .. record.Message
    if level >= LEVELS.Error then
        warn(output)
    else
        print(output)
    end
end

for levelName in pairs(LEVELS) do
    Logger[levelName] = function(self, ...)
        self:_Write(levelName, ...)
    end
end

function Logger:Child(category: string)
    return Logger.new({
        MinimumLevel = self.MinimumLevel,
        Category = self.Category .. "." .. category,
        Sink = self.Sink,
        HistoryLimit = self._HistoryLimit,
    })
end

function Logger:GetHistory()
    local copy = {}
    for index, record in ipairs(self._History) do
        copy[index] = table.clone(record)
    end
    return copy
end

function Logger:ClearHistory()
    table.clear(self._History)
end

Logger.Levels = LEVELS
return Logger
