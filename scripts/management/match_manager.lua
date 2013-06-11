--[[==============
== We Love Quiz
== Date: 05/06/13
== Time: 12:02
==============]]--

MatchManager = {}

local json = require "json"

local CurrentMatch

local matchesOfTheDayInfo


function MatchManager:requestMatches()
    Server.getMatches("http://api.kb.soccer.welovequiz.com/1/matches", function(event)
        if not event.isError then
            --print(event.response)
            local noError, jsonContent = pcall(json.decode, event.response)
            --print(noError, jsonContent)
            if noError and jsonContent then
                matchesOfTheDayInfo = jsonContent.matches
                --printTable(matchesOfTheDayInfo)
            end
        end
    end)
end

function MatchManager:setCurrentMatch(matchNum)
    if matchesOfTheDayInfo and #matchesOfTheDayInfo >= matchNum then
        CurrentMatch.matchInfo = matchesOfTheDayInfo[matchNum]
        return CurrentMatch.matchInfo.id
    else
        error("No Matches Available")
    end
end

function MatchManager:getTeamName(teamId)
    if CurrentMatch:isHomeTeamId(teamId) then
        return CurrentMatch:getHomeTeamName()
    elseif CurrentMatch:isAwayTeamId(teamId) then
        return CurrentMatch:getAwayTeamName()
    end
    error("Team Id: " .. teamId .. " is from another match")
end

---======================---
--- CURRENT MATCH OBJECT ---
---======================---
CurrentMatch = {}

function CurrentMatch:isHomeTeamId(id)
    return (self.matchInfo.home_team.id == id)
end

function CurrentMatch:isAwayTeamId(id)
    return (self.matchInfo.guest_team.id == id)
end

function CurrentMatch:getHomeTeamName()
    return self.matchInfo.home_team.name
end

function CurrentMatch:getAwayTeamName()
    return self.matchInfo.guest_team.name
end

return MatchManager