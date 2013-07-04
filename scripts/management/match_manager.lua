--[[==============
== We Love Quiz
== Date: 05/06/13
== Time: 12:02
==============]]--

MatchManager = {}

local json = require "json"

local CurrentMatch

local nextMatchesInfo

local matchesInfoTEST = {
    {
        id = "00",
        home_goals = 2,
        guest_goals = 1,
        starts_at = "2013-06-23T21:30:10+00:00",
        home_team = {
            id = "01",
            name = "Portuguesa",
            mini_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/mini_portuguesa_desportos.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/mini_2x_portuguesa_desportos.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/mini_4x_portuguesa_desportos.png"
            },
            medium_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/medium_portuguesa_desportos.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/medium_2x_portuguesa_desportos.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/medium_4x_portuguesa_desportos.png"
            },
            big_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/big_portuguesa_desportos.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/big_2x_portuguesa_desportos.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/big_4x_portuguesa_desportos.png"
            },
        },
        guest_team = {
            id = "02",
            name = "Fluminense",
            mini_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/mini_fluminense_fc.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/mini_2x_fluminense_fc.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/mini_4x_fluminense_fc.png"
            },
            medium_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/medium_fluminense_fc.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/medium_2x_fluminense_fc.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/medium_4x_fluminense_fc.png"
            },
            big_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/big_fluminense_fc.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/big_2x_fluminense_fc.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/big_4x_fluminense_fc.png"
            },
        }
    },
    {
        id = "01",
        home_goals = 0,
        guest_goals = 0,
        starts_at = "2013-06-23T19:10:50+00:00",
        home_team = {
            id = "03",
            name = "Vitória",
            mini_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/mini_ec_vitoria.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/mini_2x_ec_vitoria.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/mini_4x_ec_vitoria.png"
            },
            medium_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/medium_ec_vitoria.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/medium_2x_ec_vitoria.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/medium_4x_ec_vitoria.png"
            },
            big_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/big_ec_vitoria.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/big_2x_ec_vitoria.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/big_4x_ec_vitoria.png"
            },
        },
        guest_team = {
            id = "04",
            name = "Internacional",
            mini_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/mini_sc_internacional.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/mini_2x_sc_internacional.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/mini_4x_sc_internacional.png"
            },
            medium_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/medium_sc_internacional.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/medium_2x_sc_internacional.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/medium_4x_sc_internacional.png"
            },
            big_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/big_sc_internacional.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/big_2x_sc_internacional.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/big_4x_sc_internacional.png"
            },
        }
    },{
        id = "02",
        home_goals = 2,
        guest_goals = 1,
        starts_at = "2013-06-23T19:10:50+00:00",
        home_team = {
            id = "02",
            name = "Fluminense",
            mini_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/mini_fluminense_fc.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/mini_2x_fluminense_fc.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/mini_4x_fluminense_fc.png"
            },
            medium_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/medium_fluminense_fc.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/medium_2x_fluminense_fc.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/medium_4x_fluminense_fc.png"
            },
            big_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/big_fluminense_fc.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/big_2x_fluminense_fc.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000027/big_4x_fluminense_fc.png"
            },
        },
        guest_team = {
            id = "01",
            name = "Portuguesa",
            mini_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/mini_portuguesa_desportos.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/mini_2x_portuguesa_desportos.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/mini_4x_portuguesa_desportos.png"
            },
            medium_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/medium_portuguesa_desportos.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/medium_2x_portuguesa_desportos.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/medium_4x_portuguesa_desportos.png"
            },
            big_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/big_portuguesa_desportos.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/big_2x_portuguesa_desportos.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000009/big_4x_portuguesa_desportos.png"
            },
        }
    },
    {
        id = "03",
        home_goals = 0,
        guest_goals = 0,
        starts_at = "2013-06-23T00:00:26+00:00",
        home_team = {
            id = "04",
            name = "Internacional",
            mini_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/mini_sc_internacional.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/mini_2x_sc_internacional.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/mini_4x_sc_internacional.png"
            },
            medium_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/medium_sc_internacional.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/medium_2x_sc_internacional.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/medium_4x_sc_internacional.png"
            },
            big_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/big_sc_internacional.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/big_2x_sc_internacional.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000005/big_4x_sc_internacional.png"
            },
        },
        guest_team = {
            id = "03",
            name = "Vitória",
            mini_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/mini_ec_vitoria.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/mini_2x_ec_vitoria.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/mini_4x_ec_vitoria.png"
            },
            medium_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/medium_ec_vitoria.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/medium_2x_ec_vitoria.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/medium_4x_ec_vitoria.png"
            },
            big_logo_urls = {
                default = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/big_ec_vitoria.png",
                ["2x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/big_2x_ec_vitoria.png",
                ["4x"] = "https://wlq-soccer-kb.s3.amazonaws.com/uploads/team/logo/519c26c35ae16dbe35000003/big_4x_ec_vitoria.png"
            },
        }
    },
}

local function organizeMatchesByDate(championships)
    for i, championship in ipairs(championships) do
        local championshipMatches = championship.matches
        for j, _match in ipairs(championshipMatches) do
            local dateObj = date(_match.starts_at)
            _match.starts_at = dateObj:addseconds(getTimezoneOffset(os.time()))
        end
        for j, _match in ipairs(championshipMatches) do
            if j > 1 then
                for j = 1, j - 1 do
                    local d = date.diff(championshipMatches[j].starts_at, _match.starts_at)
                    if d:spanminutes() > 0 then
                        table.insert(championshipMatches, j, table.remove(championshipMatches, j))
                        --printDates()
                        break
                    end
                end
            end
        end
    end
end

function MatchManager:downloadTeamsLogos(params)
    local logosList = {}
    if params.sizes == "medium" then
        for i, match in ipairs(params.matches) do
            local homeUrl = match.home_team.medium_logo_urls[getImagePrefix()]
            if homeUrl then
                logosList[#logosList + 1] = {
                    url = homeUrl,
                    fileName = "logos/medium_" .. match.home_team.id .. ".png"
                }
            end
            local awayUrl = match.guest_team.medium_logo_urls[getImagePrefix()]
            if awayUrl then
                logosList[#logosList + 1] = {
                    url = awayUrl,
                    fileName = "logos/medium_" .. match.guest_team.id .. ".png"
                }
            end
        end
    elseif type(params.sizes) == "table" then
        for i, size in ipairs(params.sizes) do
            local homeUrl = MatchManager:getTeamLogoUrl(true, size)
            if homeUrl then
                logosList[#logosList + 1] = {
                    url = homeUrl,
                    fileName = MatchManager:getTeamLogoImg(true, size)
                }
            end
            local awayUrl = MatchManager:getTeamLogoUrl(false, size)
            if awayUrl then
                logosList[#logosList + 1] = {
                    url = awayUrl,
                    fileName = MatchManager:getTeamLogoImg(false, size)
                }
            end
        end
    end
    Server:downloadLogos(logosList, params.listener)
end

function MatchManager:requestMatches(listener)
    Server.getMatches("http://api.kb.soccer.welovequiz.com/1/championships", function(event)
        if not event.isError then
            --print(event.response)
            local noError, jsonContent = pcall(json.decode, event.response)
            --print(noError, jsonContent)
            if noError and jsonContent then
                nextMatchesInfo = jsonContent.championships
                --TODO
                --local bras = {}
                --for i=1, 3 do
                --    for i, v in ipairs(matchesInfoTEST) do
                --        bras[#bras + 1] = v
                --    end
                --end
                --nextMatchesInfo[#nextMatchesInfo + 1] = {name = "Brasileiro 2013", matches = bras}
                --nextMatchesInfo[#nextMatchesInfo + 1] = {name = "Brasileiro 2014", matches = bras}
                organizeMatchesByDate(nextMatchesInfo)

                MatchManager:downloadTeamsLogos({sizes = "medium", matches = nextMatchesInfo[1].matches, listener = listener})
            end
            --printTable(nextMatchesInfo)
        end
    end)
end

function MatchManager:setCurrentMatch(matchId)
    if nextMatchesInfo then
        for i, championshipInfo in ipairs(nextMatchesInfo) do
            for j, matchInfo in ipairs(championshipInfo.matches) do
                if matchInfo.id == matchId then
                    CurrentMatch.matchInfo = matchInfo
                    ScreenManager:enterMatch(matchId)
                end
            end
        end
        --printTable(CurrentMatch.matchInfo)
        --printTable(CurrentMatch.matchInfo.guest_team.medium_logo_urls)
        --print("logos", #CurrentMatch.matchInfo.guest_team.medium_logo_urls, CurrentMatch.matchInfo.guest_team.medium_logo_urls)
        --for k, v in pairs(CurrentMatch.matchInfo.guest_team.medium_logo_urls) do
        --    print(k, v)
        --end
    else
        print("No Matches Available Right Now")
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

function MatchManager:getTeamId(isHome)
    if isHome then
        return CurrentMatch:getHomeTeamId()
    end
    return CurrentMatch:getAwayTeamId()
end

function MatchManager:getTeamScore(isHome)
    if isHome then
        return CurrentMatch:getHomeTeamScore()
    end
    return CurrentMatch:getAwayTeamScore()
end

function MatchManager:getTeamLogoUrl(isHome, size)
    if isHome then
        return CurrentMatch:getHomeTeamLogoUrl(size)
    end
    return CurrentMatch:getAwayTeamLogoUrl(size)
end

function MatchManager:getTeamLogoImg(isHome, size)
    return "logos/" .. size .. "_" .. MatchManager:getTeamId(isHome) .. ".png"
end

function MatchManager:getMatchesOfTheDay()
    return nextMatchesInfo
    --[[local bras = {}
    for i=1, 3 do
        for i, v in ipairs(nextMatchesInfo) do
            bras[#bras + 1] = v
        end
    end
    local pau = {}
    for i, v in ipairs(nextMatchesInfo) do
        if i < 4 then
            pau[#pau + 1] = v
        end
    end
    local cop = {}
    for i, v in ipairs(nextMatchesInfo) do
        if i > 1  and i < 4 then
            cop[#cop + 1] = v
        end
    end
    local lib = {}
    for i, v in ipairs(nextMatchesInfo) do
        if i < 2 then
            lib[#lib + 1] = v
        end
    end
    return {
        {
            championshipName = "Brasileiro",
            matches = bras
        },
        {
            championshipName = "Paulista",
            matches = pau
        },
        {
            championshipName = "Copa do Brasil",
            matches = cop
        },
        {
            championshipName = "Libertadores",
            matches = lib
        },
        {
            championshipName = "UEFA Champions League",
            matches = nextMatchesInfo
        }
    }--]]
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

function CurrentMatch:getHomeTeamId()
    return self.matchInfo.home_team.id
end

function CurrentMatch:getAwayTeamId()
    return self.matchInfo.guest_team.id
end

function CurrentMatch:getHomeTeamScore()
    return self.matchInfo.home_goals
end

function CurrentMatch:getAwayTeamScore()
    return self.matchInfo.guest_goals
end

function CurrentMatch:getHomeTeamLogoUrl(size)
    return self.matchInfo.home_team[size .. "_logo_urls"][getImagePrefix()]
end

function CurrentMatch:getAwayTeamLogoUrl(size)
    return self.matchInfo.guest_team[size .. "_logo_urls"][getImagePrefix()]
end

return MatchManager