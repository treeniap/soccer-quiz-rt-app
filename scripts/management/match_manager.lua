--[[==============
== We Love Quiz
== Date: 05/06/13
== Time: 12:02
==============]]--

MatchManager = {}

local json = require "json"

local CurrentMatch
local Teams

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

local function onMatchOver()
    timer.performWithDelay(1, function()
        local finalResultInfo = {}

        local function getPlayerGlobalRanking()
            Server:getPlayerRanking(nil,
                function(response, status)
                    finalResultInfo.globalPoints = response.user_ranking.score
                    finalResultInfo.globalPosition = response.user_ranking.ranking
                    MatchManager.finalResultInfo = finalResultInfo
                    InGameScreen:onGameOver(finalResultInfo)
                end,
                function(response)
                    printTable(response)
                    finalResultInfo = {
                        matchPoints    = " ",
                        globalPoints   = " ",
                        globalPosition = " "
                    }
                    MatchManager.finalResultInfo = finalResultInfo
                    InGameScreen:onGameOver(finalResultInfo)
                end)
        end

        Server:getPlayerRanking(MatchManager:getMatchId(),
            function(response, status)
                finalResultInfo.matchPoints = response.user_ranking.score
                getPlayerGlobalRanking()
            end,
            function(response)
                printTable(response)
                finalResultInfo.matchPoints = " "
                getPlayerGlobalRanking()
            end)
    end)
end

local function organizeMatchesByDate(matchesList)
    for j, _match in ipairs(matchesList) do
        if j > 1 then
            for k = 1, j - 1 do
                local d = date.diff(matchesList[k].starts_at, _match.starts_at)
                if d:spanminutes() > 0 then
                    --print("Crescent", j, k, d:spanminutes())
                    table.insert(matchesList, k, table.remove(matchesList, j))
                    --printDates(matchesList)
                    break
                end
            end
        end
    end
    return matchesList
end

local function setMatchesDateObj(championships)
    for i, championship in ipairs(championships) do
        local championshipMatches = championship.incoming_matches
        for j, _match in ipairs(championshipMatches) do
            local dateObj = date(_match.starts_at)
            _match.starts_at = dateObj:addseconds(getTimezoneOffset(os.time()))
        end
        organizeMatchesByDate(championshipMatches)
    end
end

local function getSizeName(size)
    if size <= 1 then
        return "mini"
    elseif size == 2 then
        return "medium"
    end
    return "big"
end

function MatchManager:downloadTeamsLogos(params)
    local logosList = {}
    if params.sizes == "medium" then
        for i, match in ipairs(params.matches) do
            local homeUrl = match.home_team.medium_logo_urls[getImagePrefix()]
            if homeUrl then
                logosList[#logosList + 1] = {
                    url = homeUrl,
                    fileName = getLogoFileName(match.home_team.id, 2)
                }
            end
            local awayUrl = match.guest_team.medium_logo_urls[getImagePrefix()]
            if awayUrl then
                logosList[#logosList + 1] = {
                    url = awayUrl,
                    fileName = getLogoFileName(match.guest_team.id, 2)
                }
            end
        end
    elseif params.sizes == "mini" then
        for i, team in ipairs(Teams.list) do
            local url = team.mini_logo_url
            if url then
                logosList[#logosList + 1] = {
                    url = url,
                    fileName = getLogoFileName(team.id, 1)
                }
            end
        end
    elseif type(params.sizes) == "table" then
        for i, size in ipairs(params.sizes) do
            local homeUrl = MatchManager:getTeamLogoUrl(true, getSizeName(size))
            if homeUrl then
                logosList[#logosList + 1] = {
                    url = homeUrl,
                    fileName = MatchManager:getTeamLogoImg(true, size)
                }
            end
            local awayUrl = MatchManager:getTeamLogoUrl(false, getSizeName(size))
            if awayUrl then
                logosList[#logosList + 1] = {
                    url = awayUrl,
                    fileName = MatchManager:getTeamLogoImg(false, size)
                }
            end
        end
    end
    Server:downloadFilesList(logosList, params.listener)
end

local function postEnteredMatchOnFB(matchId)
    if MatchManager.enteredMatches then
        for i, id in ipairs(MatchManager.enteredMatches) do
            if id == matchId then
                return
            end
        end
    else
        MatchManager.enteredMatches = {}
    end
    MatchManager.enteredMatches[#MatchManager.enteredMatches + 1] = matchId
    local status = MatchManager:getMatchTimeStatus()
    if status == "AQUECIMENTO" then
        status = "Vai começar "
    else
        status = "Começou "
    end
    local round, championship = MatchManager:getChampionshipInfo()
    local pelStr = " pelo "
    if string.find(string.utf8upper(championship), "COPA") or
            string.find(string.utf8upper(championship), "LIBERTADORES") or
            string.find(string.utf8upper(championship), "SULAMERICANA") then
        pelStr = " pela "
    end

    Facebook:post(status .. CurrentMatch:getHomeTeamName() .. " x " ..
            CurrentMatch:getAwayTeamName() .. pelStr .. championship ..
            "! Dê seu palpite nos lances perigosos e concorra a uma camisa de futebol oficial toda semana.")
end

function MatchManager:init(onComplete)
    MatchManager:loadTeamsList(function()
        MatchManager:downloadTeamsLogos({sizes = "mini"})
        MatchManager:resquestMatches(function()
            MatchManager:downloadTeamsLogos({sizes = "medium", matches = MatchManager:getNextSevenMatches(), listener = onComplete})
        end)
    end)
end

function MatchManager:resquestMatches(onComplete)
    Server.getMatchesList(function(response, status)
        print("matches received")
        nextMatchesInfo = response.championships
        setMatchesDateObj(nextMatchesInfo)
        if onComplete then
            onComplete()
        end
    end)
end

function MatchManager:setCurrentMatch(matchId)
    if nextMatchesInfo then
        for i, championshipInfo in ipairs(nextMatchesInfo) do
            for j, matchInfo in ipairs(championshipInfo.incoming_matches) do
                if matchInfo.id == matchId then
                    CurrentMatch.matchInfo = matchInfo
                    CurrentMatch.period = nil
                    CurrentMatch.championshipRound = championshipInfo.current_round
                    CurrentMatch.championshipName = championshipInfo.name
                    CurrentMatch.championshipLogoName = championshipInfo.machine_friendly_name
                    ScreenManager:enterMatch(matchId)
                    --TODO teste: finaliza partida
                    --timer.performWithDelay(4000, onMatchOver)
                    postEnteredMatchOnFB(matchId)
                end
            end
        end
    else
        print("No Matches Available Right Now")
    end
end

function MatchManager:getChampionshipInfo()
    local logoFileName = {
        brasileiro_serie_a_2013 = "images/cbf.png",
        libertadores_da_america_2013 = "images/libertadores.png",
        copa_do_brasil_2013 = "images/cbf.png"
    }
    local getRoundName = {
        brasileiro_serie_a_2013 = function()
            return CurrentMatch.championshipRound .. "ª RODADA"
        end,
        libertadores_da_america_2013 = function()
            local round = {
                "RODADA 1",         --1
                "FASE DE GRUPOS",   --2
                "FASE DE GRUPOS",   --3
                "FASE DE GRUPOS",   --4
                "FASE DE GRUPOS",   --5
                "FASE DE GRUPOS",   --6
                "FASE DE GRUPOS",   --7
                "OITAVAS DE FINAL", --8
                "QUARTAS DE FINAL", --9
                "SEMI FINAL",       --10
                "FINAL"             --11
            }
            return round[CurrentMatch.championshipRound] or CurrentMatch.championshipRound
        end,
        copa_do_brasil_2013 = function()
            local round = {
                "FASE PRELIMINAR",  --1
                "RODADA 2",         --2
                "SEGUNDA FASE",     --3
                "TERCEIRA FASE",    --4
                "OITAVAS DE FINAL", --5
                "QUARTAS DE FINAL", --6
                "SEMI FINAL",       --7
                "FINAL"             --8
            }
            return round[CurrentMatch.championshipRound] or CurrentMatch.championshipRound
        end
    }
    return (getRoundName[CurrentMatch.championshipLogoName] and
            getRoundName[CurrentMatch.championshipLogoName]() or (CurrentMatch.championshipLogoName or "").. "ª RODADA"),
    CurrentMatch.championshipName, logoFileName[CurrentMatch.championshipLogoName]
end

function MatchManager:updateMatch(onComplete)
    Server.getMatchInfo(CurrentMatch.matchInfo.url, function(response, status)
        CurrentMatch.matchInfo = response.match
        local dateObj = date(CurrentMatch.matchInfo.starts_at)
        CurrentMatch.matchInfo.starts_at = dateObj:addseconds(getTimezoneOffset(os.time()))
        onComplete()
    end)
end

function MatchManager:getMatchTimeStatus()
    local status
    local period
    local time
    local _date = CurrentMatch.matchInfo.starts_at
    local currentDate = getCurrentDate()
    local c = date.diff(currentDate, _date)
    local minutesSpent = math.floor(c:spanminutes())
    --print(minutesSpent)
    if minutesSpent <= 0 then
        status = "AQUECIMENTO"
        period = "warming_up"
    elseif CurrentMatch.matchInfo.status == "finished" then --"started", "finished", "scheduled"
        status = "ENCERRADO"
        period = "match_over"
        onMatchOver()
    else
        time = CurrentMatch.matchInfo.elapsed_time
        if minutesSpent > 60 and time > 0 then
            status = "2° TEMPO"
            period = "second_half"
        elseif minutesSpent > 45 and time == 0 then
            time = nil
            status = "INTERVALO"
            period = "half_time"
        else
            status = "1° TEMPO"
            period = "first_half"
        end
    end
    --print(CurrentMatch.matchInfo.status, CurrentMatch.matchInfo.elapsed_time)
    if CurrentMatch.period and CurrentMatch.period ~= period then
        InGameScreen:onPeriodChange(period)
    end
    CurrentMatch.period = period

    return status, time
end

function MatchManager:getMatchId()
    if CurrentMatch and CurrentMatch.matchInfo and CurrentMatch.matchInfo.id then
        return CurrentMatch.matchInfo.id
    end
end

function MatchManager:getTeamName(teamId, isHome)
    if CurrentMatch:isHomeTeamId(teamId) then
        return CurrentMatch:getHomeTeamName()
    elseif CurrentMatch:isAwayTeamId(teamId) then
        return CurrentMatch:getAwayTeamName()
    elseif isHome then
        return CurrentMatch:getHomeTeamName()
    else
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
    return getLogoFileName(MatchManager:getTeamId(isHome), size)
end

function MatchManager:getChampionshipsList()
    return nextMatchesInfo
end

function MatchManager:getNextSevenMatches()
    local nextMatches = {}
    local currentDate = getCurrentDate()
    for i, championship in ipairs(nextMatchesInfo) do
        for i, match in pairs(championship.incoming_matches) do
            local daysDiff = currentDate:getyearday() - match.starts_at:getyearday()
            if daysDiff <= 0 then
                local c = date.diff(currentDate, match.starts_at)
                local minutesToMatch = c:spanminutes()
                if minutesToMatch < 110 then
                    nextMatches[#nextMatches + 1] = match
                end
            end
        end
    end
    nextMatches = organizeMatchesByDate(nextMatches)
    for i = #nextMatches, 1, -1 do
        if i > 7 then
            table.remove(nextMatches, i)
        else
            break
        end
    end
    return nextMatches
end

function MatchManager:loadTeamsList(listener)
    Teams:load(listener)
end

function MatchManager:getTeamsList()
    return Teams.list
end

function MatchManager:getUserTeamTwitter()
    if not UserData.attributes.favorite_team_id then
        return
    end
    local team = Teams:getTeamById(UserData.attributes.favorite_team_id)
    if team then
        return team.twitter
    end
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

---===================---
--- TEAMS LIST OBJECT ---
---===================---
Teams = {}

function Teams:load(listener)
    if self.list then
        if listener then
            listener()
        end
        return
    end

    Server.getTeamsList(function(response)
        --printTable(response)
        local badgesList = {
            ["519c26c35ae16dbe35000019"] = "images/badges/sao_paulo_fc.png",
            ["519c26c35ae16dbe3500000b"] = "images/badges/sc_corinthians_paulista.png",
            ["519c26c35ae16dbe35000025"] = "images/badges/ca_mineiro.png",
            ["519c26c35ae16dbe35000003"] = "images/badges/ec_vitoria.png",
            ["519c26c35ae16dbe35000011"] = "images/badges/cr_flamengo.png",
            ["519c26c35ae16dbe35000013"] = "images/badges/gremio_fbpa.png",
            ["519c26c35ae16dbe35000015"] = "images/badges/c_nautico_c.png",
            ["519c26c35ae16dbe35000017"] = "images/badges/aa_ponte_preta.png",
            ["519c26c35ae16dbe3500001d"] = "images/badges/ec_bahia.png",
            ["519c26c35ae16dbe35000023"] = "images/badges/coritiba_fc.png",
            ["519c26c35ae16dbe3500001f"] = "images/badges/cruzeiro_ec.png",
            ["519c26c35ae16dbe35000021"] = "images/badges/goias_ec.png",
            ["519c26c35ae16dbe35000029"] = "images/badges/ca_paranaense.png",
            ["519c26c35ae16dbe35000007"] = "images/badges/cr_vasco_g.png",
            ["51f15d2f4ea16d2299000001"] = "images/badges/se_palmeiras.png",
            ["519c26c35ae16dbe35000005"] = "images/badges/sc_internacional.png",
            ["519c26c35ae16dbe3500000d"] = "images/badges/botafogo_fr.png",
            ["519c26c35ae16dbe3500000f"] = "images/badges/santos_fc.png",
            ["519c26c35ae16dbe3500001b"] = "images/badges/criciuma_esporte_clube.png",
            ["519c26c35ae16dbe35000027"] = "images/badges/fluminense_fc.png",
            ["519c26c35ae16dbe35000009"] = "images/badges/portuguesa_desportos.png",
        }
        local teamsList = {}
        for i, team in ipairs(response.teams) do
            teamsList[team.name] = {
                id = team.id,
                badge = badgesList[team.id],
                mini_logo_url = team.mini_logo_urls[getImagePrefix()],
                medium_logo_url = team.medium_logo_urls[getImagePrefix()],
                big_logo_url = team.big_logo_urls[getImagePrefix()],
                twitter = team.twitter_id
            }
        end

        local t = {}
        function pairsByKeys (t, f)
            local a = {}
            for n in pairs(t) do table.insert(a, n) end
            table.sort(a, f)
            local i = 0      -- iterator variable
            local iter = function ()   -- iterator function
                i = i + 1
                if a[i] == nil then return nil
                else return a[i], t[a[i]]
                end
            end
            return iter
        end
        for title, value in pairsByKeys(teamsList) do
            table.insert(t, {
                name = title,
                id = value.id,
                badge = value.badge,
                mini_logo_url = value.mini_logo_url,
                medium_logo_url = value.medium_logo_url,
                big_logo_url = value.big_logo_url,
                twitter = value.twitter
            })
        end
        self.list = t

        if listener then
            listener()
        end
    end)
end

function Teams:getTeamById(id)
    for i, team in pairs(self.list) do
        if team.id == id then
            return team
        end
    end
end

return MatchManager