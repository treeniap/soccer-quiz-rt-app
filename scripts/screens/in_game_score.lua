--[[==============
== We Love Quiz
== Date: 17/05/13
== Time: 12:34
==============]]--
InGameScore = {}

local infoGroup
local transitionHandler

local function createChampionshipInfo(championshipBadge, championshipName, championshipRound)
    local championshipGroup = display.newGroup()
    local cBadge = TextureManager.newImageRect(championshipBadge, 20, 20, championshipGroup)
    cBadge.x = 0
    cBadge.y = 0
    local cName = display.newText(championshipGroup, championshipName, 0, 0, "MyriadPro-BoldCond", 10)
    cName.x = 0
    cName.y = cBadge.height*0.5 + 9
    cName:setTextColor(128)
    local cRound = display.newText(championshipGroup, championshipRound, 0, 0, "MyriadPro-BoldCond", 10)
    cRound.x = 0
    cRound.y = cName.y + 12
    cRound:setTextColor(128)
    return championshipGroup
end

local function createScore(homeTeamBadge, awayTeamBadge, homeTeamScore, awayTeamScore)
    local scoreGroup = display.newGroup()
    --- Home Team Badge
    local badgeScale = (display.screenOriginY == 0 and display.screenOriginX == 0) and 80 or 100
    local htBadge = TextureManager.newImageRect(homeTeamBadge, badgeScale, badgeScale, scoreGroup)
    htBadge.x = -110
    htBadge.y = 0
    --- Away Team Badge
    local atBadge = TextureManager.newImageRect(awayTeamBadge, badgeScale, badgeScale, scoreGroup)
    atBadge.x = 110
    atBadge.y = 0
    --- Placar
    local placar = display.newText(scoreGroup, homeTeamScore .. " - " .. awayTeamScore, 0, 0, "MyriadPro-BoldCond", 80)
    placar.x = 0
    placar.y = 10
    placar:setTextColor(0)
    return scoreGroup
end

local function createTeamsNames(homeTeamName, awayTeamName)
    local teamsNamesGroup = display.newGroup()
    local homeTeamName = display.newText(teamsNamesGroup, homeTeamName, 0, 0, "MyriadPro-BoldCond", 16)
    homeTeamName.x = 0
    homeTeamName:setTextColor(0)
    local vs = display.newText(teamsNamesGroup, " VS ", 0, 0, "MyriadPro-BoldCond", 16)
    vs.x = homeTeamName.width*0.5 + vs.width*0.5
    vs:setTextColor(128)
    local awayTeamName = display.newText(teamsNamesGroup, awayTeamName, 0, 0, "MyriadPro-BoldCond", 16)
    awayTeamName.x = vs.x + vs.width*0.5 + awayTeamName.width*0.5
    awayTeamName:setTextColor(0)
    local scale = teamsNamesGroup.width > CONTENT_WIDTH and CONTENT_WIDTH/teamsNamesGroup.width or 1
    teamsNamesGroup.xScale = scale
    teamsNamesGroup.yScale = scale
    return teamsNamesGroup
end

local function createMatchTimer(matchMinutes, matchTime)
    local timerGroup = display.newGroup()
    local matchMinutes = display.newText(timerGroup, matchMinutes .. "'", 0, 0, "MyriadPro-BoldCond", 80)
    matchMinutes.x = 0
    matchMinutes.y = 0
    matchMinutes:setTextColor(0)
    --[[
    local min = display.newText(timerGroup, "'", 0, 0, "MyriadPro-BoldCond", 80)
    min.x = matchMinutes.width*0.5 + min.width*0.5
    min.y = 0
    min:setTextColor(0)
    --]]
    local matchTime = display.newText(timerGroup, matchTime .. "° TEMPO", 0, 0, "MyriadPro-BoldCond", 32)
    matchTime.x = 0
    matchTime.y = 36
    matchTime:setTextColor(128)
    return timerGroup
end

function InGameScore:showUp()
    if transitionHandler then
        return
    end
    transitionHandler = transition.to(self, {delay = 500, time = 1000, alpha = 1, onComplete = function() transitionHandler = nil end})
end

function InGameScore:hide()
    if transitionHandler then
        transition.cancel(transitionHandler)
    end
    transitionHandler = transition.to(self, {time = 400, alpha = 0, onComplete = function() transitionHandler = nil end})
end

--championshipBadge = "pictures/fpf.png",
--championshipName  = "CAMPEONATO PAULISTA",
--championshipRound = "15ª RODADA",
--homeTeamBadge     = "pictures/clubes_bragantino.png",
--homeTeamScore     = 3,
--homeTeamName      = "CLUBE ATLÉTICO BRAGANTINO",
--awayTeamBadge     = "pictures/clubes_scaetano.png",
--awayTeamScore     = 3,
--awayTeamName      = "ASSOCIAÇÃO DESPORTIVA SÃO CAETANO",
--matchMinutes      = 32,
--matchTime         = 2,
function InGameScore:create(gameInfo)
    infoGroup = display.newGroup()
    for k, v in pairs(InGameScore) do
       infoGroup[k] = v
    end

    --- Championship
    local championshioInfo = createChampionshipInfo(gameInfo.championshipBadge, gameInfo.championshipName, gameInfo.championshipRound)
    championshioInfo.x = display.contentCenterX
    championshioInfo.y = 92 + (display.screenOriginY*0.5)
    infoGroup:insert(championshioInfo)

    --- Score
    local score = createScore(gameInfo.homeTeamBadge, gameInfo.awayTeamBadge, gameInfo.homeTeamScore, gameInfo.awayTeamScore)
    score.x = display.contentCenterX
    score.y = 170
    infoGroup:insert(score)

    --- Teams Names
    local teamsNames = createTeamsNames(gameInfo.homeTeamName, gameInfo.awayTeamName)
    teamsNames:setReferencePoint(display.CenterReferencePoint)
    teamsNames.x = display.contentCenterX
    teamsNames.y = score.y + score.height*0.5 + 6
    infoGroup:insert(teamsNames)

    --- Match Timer
    local matchTimer = createMatchTimer(gameInfo.matchMinutes, gameInfo.matchTime)
    matchTimer.x = display.contentCenterX
    matchTimer.y = 280 + (display.screenOriginY*-0.5)
    infoGroup:insert(matchTimer)

    infoGroup.alpha = 0

    return infoGroup
end

return InGameScore