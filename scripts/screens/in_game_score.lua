--[[==============
== We Love Quiz
== Date: 17/05/13
== Time: 12:34
==============]]--
InGameScore = {}

local function createChampionshipInfo()
    local championshipRound, championshipName, championshipBadge = MatchManager:getChampionshipInfo()
    local championshipGroup = display.newGroup()
    if championshipBadge then
        local cBadge = TextureManager.newImageRect(championshipBadge, 20, 20, championshipGroup)
        cBadge.x = 0
        cBadge.y = 0
    end
    local cName = display.newText(championshipGroup, championshipName, 0, 0, "MyriadPro-BoldCond", 10)
    cName.x = 0
    cName.y = 10 + 9
    cName:setTextColor(128)
    local cRound = display.newText(championshipGroup, championshipRound, 0, 0, "MyriadPro-BoldCond", 10)
    cRound.x = 0
    cRound.y = cName.y + 12
    cRound:setTextColor(128)
    return championshipGroup
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
    placar.y = 10
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
    local matchMinutes = display.newText(timerGroup, " ", 0, 0, "MyriadPro-BoldCond", 80)
    matchMinutes.x = getFontLettersSize("'")*0.5
    matchMinutes.y = 0
    matchMinutes:setTextColor(0)
    --[[
    local min = display.newText(timerGroup, "'", 0, 0, "MyriadPro-BoldCond", 80)
    min.x = matchMinutes.width*0.5 + min.width*0.5
    min.y = 0
    min:setTextColor(0)
    --]]
    local matchTime = display.newText(timerGroup, " ", 0, 0, "MyriadPro-BoldCond", 32)
    matchTime.x = 0
    matchTime.y = 42
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
            matchMinutes.text = ""
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

function InGameScore:showUp()
    if self.transitionHandler or self.alpha == 1 then
        return
    end
    self.transitionHandler = transition.to(self, {delay = 500, time = 1000, alpha = 1, onComplete = function() self.transitionHandler = nil end})
end

function InGameScore:hide(onComplete)
    if self.transitionHandler or self.alpha == 0 then
        --transition.cancel(self.transitionHandler)
        if onComplete then
            onComplete()
        end
        return
    end
    self.transitionHandler = transition.to(self, {time = 400, alpha = 0, onComplete = function()
        self.transitionHandler = nil
        if onComplete then
            onComplete()
        end
    end})
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

    --- Score
    local score = createScore(MatchManager:getTeamLogoImg(true, 3), MatchManager:getTeamLogoImg(false, 3))
    score.x = display.contentCenterX
    score.y = 156
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
    matchTimer.y = 270 + (display.screenOriginY*-0.5)
    infoGroup:insert(matchTimer)

    infoGroup.alpha = 0

    MatchManager:updateMatch(infoGroup.update, infoGroup, true)

    return infoGroup
end

return InGameScore