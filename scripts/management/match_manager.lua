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

local TeamsAssets = {               -- badges                                    -- hasAudio
    ["519c26c35ae16dbe35000019"] = {"images/badges/sao_paulo_fc.png",            true},
    ["519c26c35ae16dbe3500000b"] = {"images/badges/sc_corinthians_paulista.png", true},
    ["519c26c35ae16dbe35000025"] = {"images/badges/ca_mineiro.png",              false},
    ["519c26c35ae16dbe35000003"] = {"images/badges/ec_vitoria.png",              false},
    ["519c26c35ae16dbe35000011"] = {"images/badges/cr_flamengo.png",             false},
    ["519c26c35ae16dbe35000013"] = {"images/badges/gremio_fbpa.png",             false},
    ["519c26c35ae16dbe35000015"] = {"images/badges/c_nautico_c.png",             false},
    ["519c26c35ae16dbe35000017"] = {"images/badges/aa_ponte_preta.png",          false},
    ["519c26c35ae16dbe3500001d"] = {"images/badges/ec_bahia.png",                false},
    ["519c26c35ae16dbe35000023"] = {"images/badges/coritiba_fc.png",             false},
    ["519c26c35ae16dbe3500001f"] = {"images/badges/cruzeiro_ec.png",             false},
    ["519c26c35ae16dbe35000021"] = {"images/badges/goias_ec.png",                false},
    ["519c26c35ae16dbe35000029"] = {"images/badges/ca_paranaense.png",           false},
    ["519c26c35ae16dbe35000007"] = {"images/badges/cr_vasco_g.png",              true},
    ["51f15d2f4ea16d2299000001"] = {"images/badges/se_palmeiras.png",            true},
    ["519c26c35ae16dbe35000005"] = {"images/badges/sc_internacional.png",        false},
    ["519c26c35ae16dbe3500000d"] = {"images/badges/botafogo_fr.png",             false},
    ["519c26c35ae16dbe3500000f"] = {"images/badges/santos_fc.png",               false},
    ["519c26c35ae16dbe3500001b"] = {"images/badges/criciuma_esporte_clube.png",  false},
    ["519c26c35ae16dbe35000027"] = {"images/badges/fluminense_fc.png",           false},
    ["519c26c35ae16dbe35000009"] = {"images/badges/portuguesa_desportos.png",    false},
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
                    InGameScreen:onGameOver(finalResultInfo, CurrentMatch.enteredFinished)
                end,
                function(response)
                    --printTable(response)
                    finalResultInfo = {
                        matchPoints    = "0",
                        globalPoints   = "0",
                        globalPosition = "-"
                    }
                    MatchManager.finalResultInfo = finalResultInfo
                    InGameScreen:onGameOver(finalResultInfo, CurrentMatch.enteredFinished)
                end)
        end
        Server:getPlayerRanking(MatchManager:getMatchId(),
            function(response, status)
                finalResultInfo.matchPoints = response.user_ranking.score
                getPlayerGlobalRanking()
            end,
            function(response)
                --printTable(response)
                finalResultInfo.matchPoints = "0"
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
            _match.starts_at = date(_match.starts_at):tolocal()
        end
        organizeMatchesByDate(championshipMatches)
    end
end

local posted
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

    if not posted then
        posted = true
        Facebook:postEnterMatch(status .. CurrentMatch:getHomeTeamName() .. " x " ..
                CurrentMatch:getAwayTeamName() .. pelStr .. championship ..
                "! Dê seu palpite nos lances perigosos e concorra a uma camisa de futebol oficial toda semana.")
    end
end

function MatchManager:addListener(_listener)
    if not MatchManager.initListeners then
        MatchManager.initListeners = {}
    end
    MatchManager.initListeners[#MatchManager.initListeners + 1] = _listener
end

function MatchManager:callListener()
    for i, _listener in ipairs(MatchManager.initListeners) do
        _listener()
    end
    for i = #MatchManager.initListeners, 1, -1 do
        MatchManager.initListeners[i] = nil
    end
    MatchManager.initListeners = nil
end

function MatchManager:init()
    if not MatchManager.initListeners then
        MatchManager.initListeners = {}
    end
    MatchManager:loadTeamsList(function()
    --LoadingBall:newStage() --- 6
        Server:downloadTeamsLogos({sizes = "mini"})
        MatchManager:resquestMatches(function()
        --LoadingBall:newStage(true) --- 7
            Server:downloadTeamsLogos({sizes = "medium", matches = MatchManager:getNextEightMatches(),
                listener = function()
                    MatchManager.initialized = true
                    MatchManager:callListener()
                end})
            MatchManager:scheduleNextFavoriteTeamMatch()
        end)
    end)
end

function MatchManager:resquestMatches(onComplete)
    Server.getMatchesList(function(response, status)
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
                    --printTable(matchInfo)
                    CurrentMatch.matchInfo = matchInfo
                    CurrentMatch.period = nil
                    CurrentMatch.championshipRound = championshipInfo.current_round
                    CurrentMatch.championshipName = championshipInfo.name
                    CurrentMatch.championshipLogoName = championshipInfo.machine_friendly_name
                    CurrentMatch.enteredFinished = CurrentMatch.matchInfo.status == "finished"
                    ScreenManager:enterMatch(matchId)
                    --if DEBUG_MODE then
                    --    timer.performWithDelay(5000, onMatchOver) -- teste: finaliza partida
                    --end
                    postEnteredMatchOnFB(matchId)
                end
            end
        end
        MatchManager.finalResultInfo = nil
    else
        print("No Matches Available Right Now")
    end
end

function MatchManager:getStadiumRefereeInfo()
    return {
        referee = CurrentMatch.matchInfo.referee or " ",
        country = CurrentMatch.matchInfo.country or " ",
        state = CurrentMatch.matchInfo.state or " ",
        city = CurrentMatch.matchInfo.city or " ",
        stadium = CurrentMatch.matchInfo.stadium or " "
    }
end

function MatchManager:getChampionshipInfo()
    local logoFileName = {
        brasileiro_serie_a_2013 = "images/badges/cbf.png",
        libertadores_da_america_2013 = "images/badges/libertadores.png",
        copa_do_brasil_2013 = "images/badges/cbf.png"
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

function MatchManager:getCurrentMatchInfo()
    return CurrentMatch.matchInfo
end

function MatchManager:updateMatchInfo(currentMatchInfo)
    CurrentMatch.matchInfo = currentMatchInfo
end

local notifications = {
    matchId = nil,
    ids = {
        fifteen = nil,
        thirty = nil,
        secondHalf = nil,
        sixty = nil,
        seventyFive = nil
    }
}

local function prepareNotification(uctTime, text)
    local soundFile
    if UserData.attributes.favorite_team_id ~= "" and TeamsAssets[UserData.attributes.favorite_team_id] and TeamsAssets[UserData.attributes.favorite_team_id][2] then
        soundFile = AudioManager:getFavoriteTeamSoundFileName()
    end

    return scheduleLocalNotification(uctTime, text, soundFile)
end

local function checkLocalNotification(updatedAt, period, time)
    if not updatedAt then
        return
    end
    if notifications.matchId and notifications.matchId ~= CurrentMatch.matchInfo.id then
        for k, v in pairs(notifications.ids) do
            system.cancelNotification(v)
            notifications.ids[k] = nil
        end
    end
    notifications.matchId = CurrentMatch.matchInfo.id
    local scheduleTime
    local utcTime = updatedAt:copy()
    local text
    --print("time: ", time, "period: ", period)
    if period == "first_half" then
        if not time or time < 13 then
            -- schedule 15
            scheduleTime = "fifteen"
            utcTime:addminutes(15)
            text = "15 minutos do 1º Tempo"
        elseif time < 28 then
            -- schedule 30
            scheduleTime = "thirty"
            utcTime:addminutes(30)
            text = "30 minutos do 1º Tempo"
        else
            -- schedule secondHalf
            scheduleTime = "secondHalf"
            utcTime:addminutes(62)
            text = "Começo do 2º Tempo"
        end
    elseif period == "break" then
        -- schedule secondHalf
        scheduleTime = "secondHalf"
        utcTime:addminutes(15)
        text = "Começo do 2º Tempo"
    elseif period == "second_half" then
        if time and time < 13 then
            -- schedule 60
            scheduleTime = "sixty"
            utcTime:addminutes(15)
            text = "15 minutos do 2º Tempo"
        elseif time and time < 28 then
            -- schedule 75
            scheduleTime = "seventyFive"
            utcTime:addminutes(30)
            text = "30 minutos do 2º Tempo"
        end
    end
    if scheduleTime and notifications.ids[scheduleTime] == nil then
        local toNextNotification = date.diff(getCurrentDate(), updatedAt):spanminutes()
        if toNextNotification < 2 or toNextNotification > 62 then
            return
        end
        utcTime:toutc() -- converts to UTC
        local convertedUtc = {
            hour = utcTime:gethours(),
            min = utcTime:getminutes(),
            wday = utcTime:getweekday(),
            day = utcTime:getday(),
            month = utcTime:getmonth(),
            year = utcTime:getyear(),
            sec = utcTime:getseconds(),
            yday = utcTime:getyearday(),
            isdst = false,
        }
        notifications.ids[scheduleTime] = prepareNotification(convertedUtc, text)
    end
end

local function sanitizeStatus(matchInfo, status)
    --print(date.diff(getCurrentDate(), matchInfo.starts_at):spanminutes(), getCurrentDate(), matchInfo.starts_at)
    if matchInfo.status == "scheduled" and getCurrentDate() > matchInfo.starts_at then
        status = " "
    elseif matchInfo.status == "break" and date.diff(getCurrentDate(), matchInfo.starts_at):spanminutes() > 62 then
        status = " "
    end

    return status
end

function MatchManager:getMatchTimeStatus()
    local possibleStatus = {
        scheduled = "AQUECIMENTO",
        first_half = "1° TEMPO",
        ["break"] = "INTERVALO",
        second_half = "2° TEMPO",
        draw_break = "INTERVALO - PRORROGAÇÃO",
        extra_first_half = "1° TEMPO - PRORROGAÇÃO",
        extra_break = "INTERVALO - PRORROGAÇÃO",
        extra_second_half = "2° TEMPO - PRORROGAÇÃO",
        finished = "ENCERRADO",
    }

    local period = CurrentMatch.matchInfo.status
    local status = possibleStatus[period] or  " "
    local time

    if period == "first_half" or period == "second_half" or period == "extra_first_half" or period == "extra_second_half" then
        local updatedAt = CurrentMatch.matchInfo.status_updated_at
        if updatedAt then
            local elapsedTime = date.diff(getCurrentDate(), updatedAt):spanminutes()
            --print(getCurrentDate(), updatedAt, date.diff(getCurrentDate(), updatedAt), elapsedTime)
            time = math.floor(elapsedTime)
        end
    end

    if CurrentMatch.period and CurrentMatch.period ~= period then
        if period == "finished" then
            UserData:checkRating()
            onMatchOver()
        else
            if period == "break" then
                UserData:checkRating()
            end
            InGameScreen:onPeriodChange(period)
        end
    end
    CurrentMatch.period = period

    if not CurrentMatch.enteredFinished then
        checkLocalNotification(CurrentMatch.matchInfo.status_updated_at, period, time)
    end

    status = sanitizeStatus(CurrentMatch.matchInfo, status)

    return status, time
end

function MatchManager:onExitMatch()
    for k, v in pairs(notifications.ids) do
        system.cancelNotification(v)
        notifications.ids[k] = nil
    end
end

function MatchManager:currentMatchFinished()
    return CurrentMatch.enteredFinished
end

function MatchManager:getMatchId()
    if CurrentMatch and CurrentMatch.matchInfo and CurrentMatch.matchInfo.id then
        return CurrentMatch.matchInfo.id
    end
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
    --for i = #nextMatchesInfo, 1, -1 do
    --    local championship = nextMatchesInfo[i]
    --    for j = #championship.incoming_matches, 1, -1 do
    --        local currentDate = getCurrentDate()
    --        local daysDiff = currentDate:getyearday() - championship.incoming_matches[j].starts_at:getyearday()
    --        if daysDiff > 0 then
    --            table.remove(championship.incoming_matches, j)
    --        end
    --    end
    --    if #championship.incoming_matches == 0 then
    --        table.remove(nextMatchesInfo, i)
    --    end
    --end

    return nextMatchesInfo
end

function MatchManager:getNextEightMatches()
    if not nextMatchesInfo then
        return {}
    end
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
        if i > 8 then
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

function MatchManager:getTeamName(teamId)
    if type(teamId) == "boolean" then
        if teamId then
            return CurrentMatch:getHomeTeamName()
        else
            return CurrentMatch:getAwayTeamName()
        end
    end
    if teamId then
        local team = Teams:getTeamById(teamId)
        if team then
            return team.name
        end
    end
    return "none"
end

function MatchManager:scheduleNextFavoriteTeamMatch()
    local favoriteTeamId = UserData.attributes.favorite_team_id
    if nextMatchesInfo and favoriteTeamId then
        local after = getCurrentDate():addminutes(5)
        local scheduledDates = {}
        --print("current date", after:fmt("%A, %B %d %Y - %H:%M"))
        for i, championship in ipairs(nextMatchesInfo) do
            for j, matchInfo in ipairs(championship.incoming_matches) do
                if matchInfo.guest_team.id == favoriteTeamId or matchInfo.home_team.id == favoriteTeamId then
                    --print("matchStartsAt " .. matchInfo.starts_at, "lastNotDate " .. UserData.lastNotificationDate)
                    if matchInfo.starts_at > after and matchInfo.starts_at > UserData.lastNotificationDate then
                        local startsAt = matchInfo.starts_at:copy()
                        scheduledDates[#scheduledDates + 1] = startsAt

                        startsAt:toutc() -- converts to UTC
                        startsAt:addseconds(-300) -- advances 5 minutes

                        local convertedStartsAt = {
                            hour = startsAt:gethours(),
                            min = startsAt:getminutes(),
                            wday = startsAt:getweekday(),
                            day = startsAt:getday(),
                            month = startsAt:getmonth(),
                            year = startsAt:getyear(),
                            sec = startsAt:getseconds(),
                            yday = startsAt:getyearday(),
                            isdst = false,
                        }

                        local soundFile = "sounds/aif/16.aif"
                        if TeamsAssets[favoriteTeamId] and TeamsAssets[favoriteTeamId][2] then
                            soundFile = AudioManager:getFavoriteTeamSoundFileName()
                        end

                        scheduleLocalNotification(convertedStartsAt,
                            "Chegou a hora de " .. matchInfo.home_team.name .. " x " .. matchInfo.guest_team.name ..
                                    ". Venha jogar Chute Premiado e ganhe 5 fichas!",
                            soundFile)

                        --- Video Notification
                        if UserData.inventory.subscribed then
                            local matchWeekDay = startsAt:getweekday()
                            local daysDiff
                            if matchWeekDay <= 2 or matchWeekDay >= 6 then
                                daysDiff = 2 - matchWeekDay
                                if daysDiff < 0 then
                                    daysDiff = 7 + daysDiff
                                end
                            else
                                daysDiff = 6 - matchWeekDay
                            end
                            startsAt:adddays(daysDiff)
                            local convertedNotificationDate = {
                                hour = 16,
                                min = 0,
                                wday = startsAt:getweekday(),
                                day = startsAt:getday(),
                                month = startsAt:getmonth(),
                                year = startsAt:getyear(),
                                sec = startsAt:getseconds(),
                                yday = startsAt:getyearday(),
                                isdst = false,
                            }
                            scheduleLocalNotification(convertedNotificationDate,
                                "Novos vídeos! Venha assistir os gols da rodada.",
                                soundFile)
                        end
                    end
                end
            end
        end
        for i, _date in ipairs(scheduledDates) do
            if _date > UserData.lastNotificationDate then
                UserData.lastNotificationDate = _date
            end
        end
        UserData:save()
    else
        timer.performWithDelay(1000, function() MatchManager:scheduleNextFavoriteTeamMatch() end)
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
        local teamsList = {}
        for i, team in ipairs(response.teams) do
            teamsList[team.name] = {
                id = team.id,
                badge = TeamsAssets[team.id] and TeamsAssets[team.id][1] or "",
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
    if self.list then
        for i, team in pairs(self.list) do
            if team.id == id then
                return team
            end
        end
    end
end

return MatchManager