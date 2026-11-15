--Strict
--Made by instance.


local TeamBalancer = {}
TeamBalancer.__index = TeamBalancer

function TeamBalancer.new(teams: {Team}, maximumPerTeam: number?)
    assert(#teams > 0, "At least one team is required")
    return setmetatable({
        Teams = teams,
        MaximumPerTeam = maximumPerTeam or math.huge,
    }, TeamBalancer)
end

function TeamBalancer:GetCounts()
    local counts = {}
    for _, team in ipairs(self.Teams) do counts[team] = #team:GetPlayers() end
    return counts
end

function TeamBalancer:ChooseTeam(): Team?
    local counts = self:GetCounts()
    local candidates = {}
    local minimum = math.huge
    for _, team in ipairs(self.Teams) do
        local count = counts[team]
        if count < self.MaximumPerTeam then
            if count < minimum then
                minimum = count
                table.clear(candidates)
                table.insert(candidates, team)
            elseif count == minimum then
                table.insert(candidates, team)
            end
        end
    end
    if #candidates == 0 then return nil end
    return candidates[Random.new():NextInteger(1, #candidates)]
end

function TeamBalancer:Assign(player: Player): (boolean, string?)
    local team = self:ChooseTeam()
    if not team then return false, "No team has available capacity" end
    player.Team = team
    player.Neutral = false
    return true
end

return TeamBalancer
