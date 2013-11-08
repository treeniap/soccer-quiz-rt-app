--[[==============
== We Love Quiz
== Date: 17/05/13
== Time: 12:34
==============]]--
InGameScore = {}

InGameScore.screenName = "Score"
InGameScore.imgName = "icon_jogo_"
InGameScore.defaultState = true
local homeGoals, awayGoals

local function createChampionshipInfo()
    local championshipRound, championshipName, championshipBadge = MatchManager:getChampionshipInfo()
    local cName = display.newText(championshipName .. " - " .. championshipRound, 0, 0, "MyriadPro-Cond", 10)
    cName:setTextColor(96)
    cName:setReferencePoint(display.CenterLeftReferencePoint)
    return cName
end

local function createLocation()
    local info = MatchManager:getStadiumRefereeInfo()
    local location = display.newText(info.stadium .. ", " .. info.city .. " - " .. info.state .. ", " .. info.country, 0, 0, "MyriadPro-Cond", 10)
    location:setTextColor(96)
    location:setReferencePoint(display.CenterLeftReferencePoint)
    return location
end

local function createReferee()
    local info = MatchManager:getStadiumRefereeInfo()
    local referee = display.newText("Árbitro: " .. info.referee, 0, 0, "MyriadPro-Cond", 10)
    referee:setTextColor(96)
    referee:setReferencePoint(display.CenterLeftReferencePoint)
    return referee
end

local function createScore(homeTeamBadge, awayTeamBadge)
    local scoreGroup = display.newGroup()
    --- Home Team Badge
    local badgeScale = 48 --(CONTENT_WIDTH <= 320) and 96 or 128
    local htBadge = TextureManager.newLogo(homeTeamBadge, badgeScale, scoreGroup)
    htBadge.x = -54 - (display.screenOriginX*-0.4)
    htBadge.y = 0
    --- Away Team Badge
    local atBadge = TextureManager.newLogo(awayTeamBadge, badgeScale, scoreGroup)
    atBadge.x = 54 + (display.screenOriginX*-0.4)
    atBadge.y = 0
    --- Placar
    local placar = display.newText(scoreGroup, "-", 0, 0, "MyriadPro-BoldCond", 40)
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
    local homeTeamName = display.newText(teamsNamesGroup, string.utf8upper(MatchManager:getTeamName(true)), 0, 0, "MyriadPro-Cond", 10)
    homeTeamName.x = -54 - (display.screenOriginX*-0.25)
    homeTeamName:setTextColor(0)
    --local vs = display.newText(teamsNamesGroup, " VS ", 0, 0, "MyriadPro-BoldCond", 16)
    --vs.x = homeTeamName.width*0.5 + vs.width*0.5
    --vs:setTextColor(128)
    local awayTeamName = display.newText(teamsNamesGroup, string.utf8upper(MatchManager:getTeamName(false)), 0, 0, "MyriadPro-Cond", 10)
    awayTeamName.x = 54 + (display.screenOriginX*-0.25)
    awayTeamName:setTextColor(0)
    --local scale = teamsNamesGroup.width > CONTENT_WIDTH and CONTENT_WIDTH/teamsNamesGroup.width or 1
    --teamsNamesGroup.xScale = scale
    --teamsNamesGroup.yScale = scale
    return teamsNamesGroup
end


function InGameScore:updateLive()
    Server.getLive(function(response, status)
        if self.isDestroyed then
            return
        end
        self.timerLive = timer.performWithDelay(60000, function() self:updateLive() end)
        if not response or not response.live_feed or self.liveIndex >= #response.live_feed then
            if self.liveIndex == 0 and not self.aquecimentoTxt then
                local status, time = MatchManager:getMatchTimeStatus()
                local aquecimentoTxt = display.newText(self, status, 0, 0, "MyriadPro-BoldCond", 32)
                aquecimentoTxt.x = display.contentCenterX
                aquecimentoTxt.y = display.contentCenterY
                aquecimentoTxt:setTextColor(135)
                self.aquecimentoTxt = aquecimentoTxt
            end
            return
        end
        if self.aquecimentoTxt then
            self.aquecimentoTxt:removeSelf()
            self.aquecimentoTxt = nil
        end
        self.liveIndex = #response.live_feed
        if self.live then
            self.live:removeSelf()
        end
        local widget = require "widget"
        -- Create a ScrollView
        local _maskFile = "images/masks/live_mask"
        if display.screenOriginY < -40 then
            _maskFile = _maskFile .. "_iphone5"
        elseif display.screenOriginY < -20 then
            _maskFile = _maskFile .. "_android"
        end
        _maskFile = _maskFile .. ".png"

        local liveScroll = widget.newScrollView
            {
                width = 320,
                height = 178 + (display.screenOriginY*-2),
                maskFile = _maskFile,
                hideBackground = true,
                hideScrollBar = true,
                horizontalScrollDisabled = true,
                friction = 0.8,
                listener = function(event)
                    if event.phase == "moved" then
                        local dX = math.abs(event.x - event.xStart)
                        local dY = math.abs(event.y - event.yStart)
                        -- If our finger has moved more than the desired range
                        if dY < 25 and dX > 50 then
                            InGameScreen:getStateManager().touchHandler:takeFocus(event)
                        end
                    end
                end
            }
        local yPos = 2
        for i = #response.live_feed, 1, -1 do
            local v = response.live_feed[i]
            local TIME_X = 22
            local lineStartY = yPos

            liveScroll:insert(TextureManager.newHorizontalLine(display.contentCenterX, yPos, display.contentWidth*1.05))

            local descTxt = display.newText(v.description, 0, 0, display.contentWidth*.7, 0, "MyriadPro-Regular", 14)
            descTxt:setReferencePoint(display.CenterLeftReferencePoint)
            descTxt:setTextColor(0)
            descTxt.x = 52
            yPos = yPos + descTxt.height*.5 + 12
            descTxt.y = yPos
            liveScroll:insert(descTxt)

            if v.key and TextureManager.checkFrameIndex("tag_" .. v.key) then
                local tag = TextureManager.newImage("tag_" .. v.key)
                tag.x = 300
                tag.y = yPos
                liveScroll:insert(tag)
            end

            local myCircle = display.newCircle(TIME_X, yPos, 12)
            myCircle:setFillColor(0, 0)
            myCircle.strokeWidth = 3
            myCircle:setStrokeColor(135)
            liveScroll:insert(myCircle)

            local minTxt = display.newText(v.minute or "", 0, 0, "MyriadPro-BoldCond", 16)
            minTxt:setTextColor(135)
            minTxt.x = TIME_X
            minTxt.y = yPos + 2
            liveScroll:insert(minTxt)

            local lineTop = display.newLine(TIME_X, lineStartY, TIME_X, yPos - 12)
            lineTop:setColor(135)
            lineTop.width = 3
            liveScroll:insert(lineTop)

            lineStartY = yPos + 12
            yPos = yPos + descTxt.height*.5 + 12

            local lineBottom = display.newLine(TIME_X, lineStartY, TIME_X, yPos)
            lineBottom:setColor(135)
            lineBottom.width = 3
            liveScroll:insert(lineBottom)
        end
        liveScroll:insert(TextureManager.newHorizontalLine(display.contentCenterX, yPos, display.contentWidth*1.05))


        liveScroll.x = 0
        liveScroll.y = 154 + (display.screenOriginY)
        self.live = liveScroll
        self:insert(liveScroll)
    end)
end

function InGameScore:update()
    InGameScore:updateScore()
    InGameScreen:updateTime()
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
            if response.match.home_goals > homeGoals then
                --InGameScreen:goal()
                onGoal(response, "homeTeam", response.match.home_team.id, currentMatchInfo.guest_team.id == UserData.attributes.favorite_team_id)
            end
            if response.match.guest_goals > awayGoals then
                onGoal(response, "awayTeam", response.match.guest_team.id, currentMatchInfo.home_team.id == UserData.attributes.favorite_team_id)
            end
        end
        homeGoals = response.match.home_goals
        awayGoals = response.match.guest_goals
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
    if self.timerLive then
        timer.cancel(self.timerLive)
    end
    self:updateMatch()
    self:updateLive()
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

    infoGroup.liveIndex = 0

    local minutoaminutoTxt = display.newText(infoGroup, "MINUTO A MINUTO", 8, 88 + (display.screenOriginY), "MyriadPro-BoldCond", 16)
    minutoaminutoTxt:setTextColor(32)
    minutoaminutoTxt:setReferencePoint(display.CenterLeftReferencePoint)

    --- Championship
    local championshipInfo = createChampionshipInfo()
    championshipInfo.x = 8
    championshipInfo.y = minutoaminutoTxt.y + 14
    infoGroup:insert(championshipInfo)

    --- Location
    local locationInfo = createLocation()
    locationInfo.x = 8
    locationInfo.y = championshipInfo.y + 12
    infoGroup:insert(locationInfo)

    --- Referee
    local refereeInfo = createReferee()
    refereeInfo.x = 8
    refereeInfo.y = locationInfo.y + 12
    infoGroup:insert(refereeInfo)

    --- Score
    local score = createScore(MatchManager:getTeamLogoImg(true, 2), MatchManager:getTeamLogoImg(false, 2))
    score.x = display.contentWidth*.75
    score.y = championshipInfo.y
    infoGroup:insert(score)

    --- Teams Names
    local teamsNames = createTeamsNames()
    teamsNames.x = display.contentWidth*.75
    teamsNames.y = score.y + score.height*0.45
    infoGroup:insert(teamsNames)

    homeGoals, awayGoals = 0, 0
    infoGroup:updateMatch(true)
    infoGroup:updateLive()

    if MatchManager:currentMatchFinished() then
        infoGroup.defaultState = false
    end

    return infoGroup
end

function InGameScore:destroy()
    Goal:close()
    if self.timer then
        timer.cancel(self.timer)
    end
    if self.timerLive then
        timer.cancel(self.timerLive)
    end
    if self.live then
        self.live:removeSelf()
        self.live = nil
    end
    self:removeSelf()
    self.isDestroyed = true
end

return InGameScore