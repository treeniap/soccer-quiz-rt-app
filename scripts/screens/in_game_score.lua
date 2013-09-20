--[[==============
== We Love Quiz
== Date: 17/05/13
== Time: 12:34
==============]]--
InGameScore = {}

InGameScore.screenName = "Score"
InGameScore.imgName = "icon_jogo_"
InGameScore.defaultState = true

local function createChampionshipInfo()
    local championshipRound, championshipName, championshipBadge = MatchManager:getChampionshipInfo()
    local championshipGroup = display.newGroup()
    if championshipBadge then
        local cBadge = TextureManager.newImageRect(championshipBadge, 20, 20, championshipGroup)
        cBadge.x = 0
        cBadge.y = 0
    end
    local cName = display.newText(championshipGroup, championshipName .. " - " .. championshipRound, 0, 0, "MyriadPro-BoldCond", 10)
    cName.x = 0
    cName.y = 10 + 9
    cName:setTextColor(128)
    --local cRound = display.newText(championshipGroup, championshipRound, 0, 0, "MyriadPro-BoldCond", 10)
    --cRound.x = 0
    --cRound.y = cName.y + 12
    --cRound:setTextColor(128)
    return championshipGroup
end

local function createLocationAndReferee()
    local info = MatchManager:getStadiumRefereeInfo()
    local locationRefereeGroup = display.newGroup()
    local location = display.newText(locationRefereeGroup, info.stadium .. ", " .. info.city .. " - " .. info.state .. ", " .. info.country, 0, 0, "MyriadPro-BoldCond", 10)
    location.x = 0
    location.y = 10 + 9
    location:setTextColor(128)
    local referee = display.newText(locationRefereeGroup, "Árbitro: " .. info.referee, 0, 0, "MyriadPro-BoldCond", 10)
    referee.x = 0
    referee.y = location.y + 12
    referee:setTextColor(128)
    return locationRefereeGroup
end

local function createScore(homeTeamBadge, awayTeamBadge)
    local scoreGroup = display.newGroup()
    --- Home Team Badge
    local badgeScale = 96--(CONTENT_WIDTH <= 320) and 96 or 128
    local htBadge = TextureManager.newLogo(homeTeamBadge, badgeScale, scoreGroup)
    htBadge.x = -106 - (display.screenOriginX*-0.4)
    htBadge.y = 0
    --- Away Team Badge
    local atBadge = TextureManager.newLogo(awayTeamBadge, badgeScale, scoreGroup)
    atBadge.x = 106 + (display.screenOriginX*-0.4)
    atBadge.y = 0
    --- Placar
    local placar = display.newText(scoreGroup, "-", 0, 0, "MyriadPro-BoldCond", 72)
    placar.x = 0
    placar.y = 20
    placar:setTextColor(0)
    function InGameScore:updateScore()
        placar.text = MatchManager:getTeamScore(true) .. " - " .. MatchManager:getTeamScore(false)
    end
    return scoreGroup
end

local function createTeamsNames()
    local teamsNamesGroup = display.newGroup()
    local homeTeamName = display.newText(teamsNamesGroup, string.utf8upper(MatchManager:getTeamName(true)), 0, 0, "MyriadPro-BoldCond", 16)
    homeTeamName.x = -106 - (display.screenOriginX*-0.25)
    homeTeamName:setTextColor(0)
    --local vs = display.newText(teamsNamesGroup, " VS ", 0, 0, "MyriadPro-BoldCond", 16)
    --vs.x = homeTeamName.width*0.5 + vs.width*0.5
    --vs:setTextColor(128)
    local awayTeamName = display.newText(teamsNamesGroup, string.utf8upper(MatchManager:getTeamName(false)), 0, 0, "MyriadPro-BoldCond", 16)
    awayTeamName.x = 106 + (display.screenOriginX*-0.25)
    awayTeamName:setTextColor(0)
    --local scale = teamsNamesGroup.width > CONTENT_WIDTH and CONTENT_WIDTH/teamsNamesGroup.width or 1
    --teamsNamesGroup.xScale = scale
    --teamsNamesGroup.yScale = scale
    return teamsNamesGroup
end

local function createMatchTimer()
    local timerGroup = display.newGroup()
    local matchMinutes = display.newText(timerGroup, " ", 0, 0, "MyriadPro-BoldCond", 64)
    matchMinutes.x = getFontLettersSize("'")*0.5
    matchMinutes.y = 0
    matchMinutes:setTextColor(0)
    --[[
    local min = display.newText(timerGroup, "'", 0, 0, "MyriadPro-BoldCond", 80)
    min.x = matchMinutes.width*0.5 + min.width*0.5
    min.y = 0
    min:setTextColor(0)
    --]]
    local matchTime = display.newText(timerGroup, " ", 0, 0, "MyriadPro-BoldCond", 24)
    matchTime.x = 0
    matchTime.y = 27
    matchTime:setTextColor(128)
    function InGameScore:updateTime()
        local status, time = MatchManager:getMatchTimeStatus()
        if time then
            if time > 45 then
                matchMinutes.text = "45'+"
            else
                matchMinutes.text = time .. "'"
            end
        else
            matchMinutes.text = " "
        end
        matchTime.text = status
        matchMinutes:setReferencePoint(display.CenterReferencePoint)
        matchMinutes.x = getFontLettersSize("'")*0.5
        matchTime:setReferencePoint(display.CenterReferencePoint)
        matchTime.x = 0
    end
    return timerGroup
end

function InGameScore:update()
    InGameScore:updateScore()
    InGameScore:updateTime()
end

local function onGoal(response, scoringTeam, scoringTeamId, isFavoriteTeamAgainstGoal)
    if isFavoriteTeamAgainstGoal then -- se o time favorito sofreu o gol
        AudioManager.playAudio("betWrong")
        return
    end
    Goal:new({
        scoringTeam = scoringTeam,
        homeTeam = {
            name = response.match.home_team.name,
            score = response.match.home_goals,
        },
        awayTeam = {
            name = response.match.guest_team.name,
            score = response.match.guest_goals,
        }
    })
    AudioManager.playAudio("betRight")
end

function InGameScore:updateMatch(isFirst)
    local currentMatchInfo = MatchManager:getCurrentMatchInfo()
    Server.getMatchInfo(currentMatchInfo.url, function(response, status)
        if self.isDestroyed then
            return
        end
        if not isFirst then
            if response.match.home_goals > currentMatchInfo.home_goals then
                --InGameScreen:goal()
                onGoal(response, "homeTeam", response.match.home_team.id, currentMatchInfo.guest_team.id == UserData.attributes.favorite_team_id)
            end
            if response.match.guest_goals > currentMatchInfo.guest_goals then
                onGoal(response, "awayTeam", response.match.guest_team.id, currentMatchInfo.home_team.id == UserData.attributes.favorite_team_id)
            end
        end
        currentMatchInfo = response.match
        currentMatchInfo.starts_at = date(currentMatchInfo.starts_at):tolocal()
        if currentMatchInfo.status_updated_at then
            currentMatchInfo.status_updated_at = date(currentMatchInfo.status_updated_at):tolocal()
        else
            currentMatchInfo.status_updated_at = getCurrentDate():addseconds(-math.floor(system.getTimer()/1000))
        end

        MatchManager:updateMatchInfo(currentMatchInfo)
        self:update()

        local elapsedTime = date.diff(getCurrentDate(), currentMatchInfo.status_updated_at):spanminutes()
        local nextUpdateTime = elapsedTime - math.floor(elapsedTime)
        nextUpdateTime = math.floor(60000 - 60000*nextUpdateTime)
        if nextUpdateTime >= 30000 then
            nextUpdateTime = 30000
        end
        self.timer = timer.performWithDelay(nextUpdateTime, function() self:updateMatch(false) end)
    end)
end

function InGameScore:forceUpdateMatch()
    if self.timer then
        timer.cancel(self.timer)
    end
    self:updateMatch()
end

function InGameScore:toFront()
    self.isVisible = true
end

function InGameScore:toBack()
    self.isVisible = false
end

function InGameScore:create()
    local infoGroup = display.newGroup()
    for k, v in pairs(InGameScore) do
       infoGroup[k] = v
    end

    --- Championship
    local championshioInfo = createChampionshipInfo()
    championshioInfo.x = display.contentCenterX
    championshioInfo.y = 88 + (display.screenOriginY*0.5)
    infoGroup:insert(championshioInfo)

    --- Location and Referee
    local locationAndReferee = createLocationAndReferee()
    locationAndReferee.x = display.contentCenterX
    locationAndReferee.y = championshioInfo.y + 12
    infoGroup:insert(locationAndReferee)

    --- Score
    local score = createScore(MatchManager:getTeamLogoImg(true, 3), MatchManager:getTeamLogoImg(false, 3))
    score.x = display.contentCenterX
    score.y = 184
    infoGroup:insert(score)

    --- Teams Names
    local teamsNames = createTeamsNames()
    --teamsNames:setReferencePoint(display.CenterReferencePoint)
    teamsNames.x = display.contentCenterX
    teamsNames.y = score.y + score.height*0.5 + (display.screenOriginY*-0.25)
    infoGroup:insert(teamsNames)

    --- Match Timer
    local matchTimer = createMatchTimer()
    matchTimer.x = display.contentCenterX
    matchTimer.y = 290 + (display.screenOriginY*-0.5)
    infoGroup:insert(matchTimer)

    infoGroup:updateMatch(true)

    return infoGroup
end

function InGameScore:destroy()
    Goal:close()
    if self.timer then
        timer.cancel(self.timer)
    end
    self:removeSelf()
    self.isDestroyed = true
end

return InGameScore