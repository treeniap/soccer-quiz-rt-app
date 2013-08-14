--[[==============
== We Love Quiz
== Date: 21/06/13
== Time: 17:28
==============]]--
InitialScreen = {}

require "scripts.widgets.view.button_home_screen"

local initialScreenGroup
local bottomRanking
local topBar
local matchesFoil
local logo
local playBtn
local rankingBtn
local adjustScale
local matchesGroup
local isOpeningMatch
local updateTimer
local updateMatchesFoil
local isUpdatingMatchesFoil

local function createLogo()
    logo = TextureManager.newImage("stru_logotipo", initialScreenGroup)
    logo.x = logo.width*0.5
    logo.y = SCREEN_TOP + 130
    logo.isVisible = false
    function logo:showUp(onComplete)
        self.isVisible = true
        transition.from(self, {time = 500, x = SCREEN_LEFT - self.width, transition = easeOutQuad, onComplete = onComplete})
        AudioManager.playAudio("showLogo")
    end
    function logo:hide()
        self.isVisible = true
        transition.to(self, {time = 500, x = SCREEN_LEFT - self.width, transition = easeInQuad})
    end
    return logo
end

local function createButtons()
    local buttonGroup = display.newGroup()

    local buttonBg = TextureManager.newImageRect("images/stru_bar_gold_mid.png", CONTENT_WIDTH, 47, buttonGroup)
    buttonBg.x = display.contentCenterX
    buttonBg.y = display.contentCenterY

    local buttonTxt = display.newText(buttonGroup, "JOGAR", 0, 0, "MyriadPro-BoldCond", 28)
    buttonTxt.x = 96 + display.screenOriginX*0.5
    buttonTxt.y = display.contentCenterY
    buttonTxt:setTextColor(0)

    return buttonGroup
end

local function createFoilLine(x, y, lineWidth)
    local lineGroup = display.newGroup()
    --local horLine = display.newLine(lineGroup, 0, 0, 1, 0)
    --horLine:setColor(102, 16, 19, 64)
    local horLine = display.newLine(lineGroup, 0, 0, lineWidth, 0)
    horLine:setColor(102, 16, 19)

    --local horLine = display.newLine(lineGroup, -1, 1, 0, 1)
    --horLine:setColor(242, 155, 158, 64)
    local horLine = display.newLine(lineGroup, 0, 1, lineWidth, 1)
    horLine:setColor(242, 155, 158)

    lineGroup:setReferencePoint(display.CenterRightReferencePoint)
    lineGroup.x = x
    lineGroup.y = y
    lineGroup.baseY = y

    return lineGroup
end

local function createTouchHandler(y)
    local touchHandler = display.newRect(0, 0, 162 + (-display.screenOriginX), 80)
    touchHandler:setReferencePoint(display.TopCenterReferencePoint)
    touchHandler.x = -71 + (display.screenOriginX*0.5) + (160 + (-display.screenOriginX))*0.5 - 4 + display.screenOriginX*0.5
    touchHandler.y = y + 2
    touchHandler.strokeWidth = 4
    touchHandler:setStrokeColor(0, 0, 0, 64)
    local g = graphics.newGradient(
        { 180,  180,  180, 128 },
        { 0,  0,  0, 96 },
        "down" )
    touchHandler:setFillColor( g )
    touchHandler.blendMode = "add"
    touchHandler.alpha = 0.01
    return touchHandler
end

local function createMatchView(match, y, currentDate)
    local matchGroup = display.newGroup()

    local time
    local daysDiff = currentDate:getyearday() - match.starts_at:getyearday()
    if daysDiff > 0 then
        time = display.newText("ENCERRADO", 0, 0, "MyriadPro-BoldCond", 16)
    elseif daysDiff < -1 then
        time = display.newText(string.utf8upper(match.starts_at:fmt("%a %d %b %Y - %H:%M")), 0, 0, "MyriadPro-BoldCond", 16)
    elseif daysDiff == 0 then
        local c = date.diff(currentDate, match.starts_at)
        --print(c:spanminutes())
        local minutesToMatch = c:spanminutes()
        if minutesToMatch > 110 then
            time = display.newText("ENCERRADO", 0, 0, "MyriadPro-BoldCond", 16)
        elseif minutesToMatch >= -5 then
            time = display.newText("JOGUE AGORA", 0, 0, "MyriadPro-BoldCond", 16)
            local touchHandler = createTouchHandler(y)
            matchesGroup:insert(touchHandler)
            matchGroup.touchHandler = touchHandler
            print(UserData.lastFavTeamMatchId)
            if UserData.lastFavTeamMatchId ~= match.id and
                    (match.home_team.id == UserData.attributes.favorite_team_id or
                    match.guest_team.id == UserData.attributes.favorite_team_id) then
                Server:claimFavoriteTeamCoins(match.id)
            end
        else
            time = display.newText("HOJE - " .. string.utf8upper(match.starts_at:fmt("%H:%M")), 0, 0, "MyriadPro-BoldCond", 16)
        end
    elseif daysDiff == -1 then
        time = display.newText("AMANHÃ - " .. string.utf8upper(match.starts_at:fmt("%H:%M")), 0, 0, "MyriadPro-BoldCond", 16)
    end
    --print(daysDiff, string.utf8upper(match.starts_at:fmt("%a %d %b %Y - %H:%M")), time.text)
    time:setReferencePoint(display.TopCenterReferencePoint)
    time.x = -66
    time.y = 0

    local vs = display.newText("VS", 0, 0, "MyriadPro-BoldCond", 16)
    vs:setReferencePoint(display.TopRightReferencePoint)
    vs.x = -59
    vs.y = 48

    local homeTeamBadge = TextureManager.newLogo(getLogoFileName(match.home_team.id, 2), 64)
    homeTeamBadge.x = -110
    homeTeamBadge.y = 50
    local awayTeamBadge = TextureManager.newLogo(getLogoFileName(match.guest_team.id, 2), 64)
    awayTeamBadge.x = -25
    awayTeamBadge.y = 50

    matchGroup:insert(time)
    matchGroup:insert(vs)
    matchGroup:insert(homeTeamBadge)
    matchGroup:insert(awayTeamBadge)

    matchGroup:setReferencePoint(display.TopRightReferencePoint)
    matchGroup.x = (160 + (-display.screenOriginX))*0.5 - 4 + display.screenOriginX*0.5
    matchGroup.y = y + 4
    matchGroup.baseY = y + 4
    return matchGroup
end

local function createMatchesView(x, y)
    local widget = require "widget"
    -- Create a ScrollView
    local _maskFile = "images/matches_foil/matchesfoil_mask"
    if display.screenOriginY < 0 then
        _maskFile = _maskFile .. "_iphone5"
    end
    _maskFile = _maskFile .. ".png"

    local matches = MatchManager:getNextSevenMatches()
    --local scrollHeight = #matches*96 + (-display.screenOriginY)
    --scrollHeight = 1*96 + (-display.screenOriginY)
    matchesGroup = widget.newScrollView
        {
            width = 160 + (-display.screenOriginX),
            height = 376 + (-display.screenOriginY),
            --scrollHeight = scrollHeight,
            topPadding = 100 + display.screenOriginY,
            bottomPadding = 40, -- -1550 - display.screenOriginY*5.5,
            maskFile = _maskFile,
            hideBackground = true,
            horizontalScrollDisabled = true,
            verticalScrollDisabled = #matches < 4,
            friction = 0.8,
            --listener = adjustScale,
        }

    local function onEnterMatch(button, event)
        if isOpeningMatch then
            return true
        end
        if event.phase == "began" then
            display.getCurrentStage():setFocus(button)
            button.isFocus = true
            button.alpha = 1
            button.group.x = button.group.x + 1
            button.group.y = button.group.y + 1
            AudioManager.playAudio("btn")
        elseif button.isFocus then
            if event.phase == "moved" then
                local dy = math.abs( ( event.y - event.yStart ) )
                -- If our finger has moved more than the desired range
                if dy > 10 then
                    button.isFocus = nil
                    button.alpha = 0.01
                    button.group.x = button.group.x - 1
                    button.group.y = button.group.y - 1
                    -- Pass the focus back to the scrollView
                    matchesGroup:takeFocus( event )
                end
            elseif event.phase == "ended" then
                button.alpha = 0.01
                button.group.x = button.group.x - 1
                button.group.y = button.group.y - 1
                display.getCurrentStage():setFocus(nil)
                MatchManager:setCurrentMatch(button.matchId)
                isOpeningMatch = true
                button:removeEventListener("touch", button)
                AudioManager.playAudio("hideInitialScreen")
            end
        end
        return true
    end

    matchesGroup.lines = {}
    matchesGroup.matches = {}
    local currentDate = getCurrentDate()
    local yPos = 0
    local nextUpdateTime
    for i = #matches, 1, -1 do
        local match = matches[i]
        --if i > 1 then
        --    break
        --end
        matchesGroup.lines[#matchesGroup.lines + 1] = createFoilLine(80 + (-display.screenOriginX), yPos,  160 + (-display.screenOriginX))
        matchesGroup:insert(matchesGroup.lines[#matchesGroup.lines])
        local matchView = createMatchView(match, yPos, currentDate)
        matchesGroup:insert(matchView)
        if matchView.touchHandler then
            matchView.touchHandler.matchId = match.id
            matchView.touchHandler.group = matchView
            matchView.touchHandler.touch = onEnterMatch
            matchView.touchHandler:addEventListener("touch", matchView.touchHandler)
        end
        matchesGroup.matches[#matchesGroup.matches + 1] = matchView
        yPos = yPos + 84 --(120*(((yPos)*1.4 + 500)/1000))

        local c = date.diff(currentDate, match.starts_at)
        local minutesToMatch = -c:spanminutes() - 5
        if minutesToMatch <= 0 then
            minutesToMatch = 110 + minutesToMatch
        end
        if not nextUpdateTime or nextUpdateTime > minutesToMatch then
            if minutesToMatch > 0 then
                nextUpdateTime = minutesToMatch
            end
        end
    end
    if nextUpdateTime and nextUpdateTime > 0 and nextUpdateTime < 45 then
        updateTimer = timer.performWithDelay(nextUpdateTime*MINUTE_DURATION, updateMatchesFoil)
    end

    matchesGroup.x = x + 3
    matchesGroup.y = y
    matchesGroup.maskX = 14 + display.screenOriginX*0.5 + display.screenOriginY*0.1

    local lastContY = 0
    local lastSFXPlayY = 0
    function adjustScale()
        if not initialScreenGroup or not matchesGroup then
            return
        end
        if matchesGroup.getContentPosition then
            local contX, contY = matchesGroup:getContentPosition()
            if lastContY ~= contY then
                --local yPos = 0
                --print(contY)
                for i, _obj in ipairs(matchesGroup.matches) do
                    --print(_obj.baseY, contY)
                    local scale = ((_obj.y + contY)*1.4 + 500)/1000
                    --print(scale)
                    if scale < 0.1 then
                        scale = 0.1
                    elseif scale > 1 then
                        scale = 1
                    end
                    _obj.xScale = scale
                    _obj.yScale = scale
                    --_obj.y = yPos + 4
                    --matchesGroup.lines[i].y = yPos
                    --print(yPos)
                    --yPos = yPos + (120*(((_obj.y + contY)*1.4 + 500)/1000))
                    --print(_obj.y, _obj.baseY)
                end
                local SFXY = (contY - 120) % 84
                if lastContY > contY then
                    if SFXY >= lastSFXPlayY then
                        AudioManager.playAudio("matchesFoil")
                    end
                else
                    if SFXY <= lastSFXPlayY then
                        AudioManager.playAudio("matchesFoil")
                    end
                end
                lastSFXPlayY = SFXY
                lastContY = contY
            end
        end
    end
    Runtime:addEventListener("enterFrame", adjustScale)

    return matchesGroup
end

local function createMatchesFoil(onComplete)
    matchesFoil = display.newGroup()
    local matchesFoilCenter = TextureManager.newImageRect("images/matches_foil/stru_mainfoil_center.png", 72 + (-display.screenOriginX), 421, matchesFoil) --88 420
    matchesFoilCenter.x = SCREEN_RIGHT - matchesFoilCenter.width*0.5
    matchesFoilCenter.y = display.contentCenterY
    local matchesFoilBorder = TextureManager.newImageRect("images/matches_foil/stru_mainfoil_border.png", 88, 421, matchesFoil) --88 420
    matchesFoilBorder.x = matchesFoilCenter.x - matchesFoilCenter.width*0.5 - matchesFoilBorder.width*0.5
    matchesFoilBorder.y = display.contentCenterY
    local matchesGroup = createMatchesView(SCREEN_RIGHT - (160 + (-display.screenOriginX))*0.5, display.contentCenterY - 210)
    matchesFoil:insert(matchesGroup)
    matchesFoil.isVisible = false
    function matchesFoil:showUp(onComplete)
        self.isVisible = true
        transition.from(self, {time = 1000, x = SCREEN_RIGHT + self.width, transition = easeOutQuad, onComplete = function()
            matchesGroup:scrollTo("bottom", {time = 1000})
            onComplete()
        end})
        AudioManager.playAudio("showNextMatches", 300)
    end
    function matchesFoil:hide(onComplete)
        transition.to(self, {time = 300, x = SCREEN_RIGHT + self.width, transition = easeInQuad, onComplete = function()
            self.isVisible = false
            onComplete()
        end})
    end
    matchesFoil:showUp(function()
        playBtn:showUp(onComplete)
        rankingBtn:showUp()
    end)
    return matchesFoil
end

function InitialScreen:showUp(onComplete)
    isUpdatingMatchesFoil = true
    bottomRanking:showUp(function()
        topBar:showUp()
        logo:showUp()
        initialScreenGroup:insert(4, createMatchesFoil(function()
            isUpdatingMatchesFoil = false
            if onComplete then
                onComplete()
            end
        end))
    end)
end

function updateMatchesFoil()
    if isUpdatingMatchesFoil then
        return
    end
    isUpdatingMatchesFoil = true
    if updateTimer then
        timer.cancel(updateTimer)
        updateTimer = nil
    end
    Runtime:removeEventListener("enterFrame", adjustScale)
    display.getCurrentStage():setFocus(nil)
    if playBtn then
        playBtn:hide(function()
            matchesFoil:hide(function()
                matchesFoil:removeSelf()
                initialScreenGroup:insert(4, createMatchesFoil(function() isUpdatingMatchesFoil = false end))
            end)
        end)
    end
    if rankingBtn then
        rankingBtn:hide()
    end
end

function InitialScreen:updateTotalCoins()
    topBar:updateTotalCoins(UserData.inventory.coins)
end

function InitialScreen.onAppResume()
    if matchesFoil then
        updateMatchesFoil()
    end
end

function InitialScreen:new()
    isOpeningMatch = false
    isUpdatingMatchesFoil = false
    initialScreenGroup = display.newGroup()

    createLogo()

    playBtn = BtnHomeScreen:new(display.contentCenterY, "JOGAR", true, function()
        MatchManager:resquestMatches()
        ScreenManager:show("select_match")
        AudioManager.playAudio("hideInitialScreen")
    end)
    initialScreenGroup:insert(playBtn)
    rankingBtn = BtnHomeScreen:new(display.contentCenterY + 47, "RANKING", false, function()
        ScreenManager:show("ranking")
        AudioManager.playAudio("hideInitialScreen")
    end)
    initialScreenGroup:insert(rankingBtn)

    bottomRanking = BottomRanking:new(UserData:getUserPicture(), true)
    initialScreenGroup:insert(bottomRanking)

    topBar = TopBar:new(true)
    topBar:updateTotalCoins(UserData.inventory.coins)
    initialScreenGroup:insert(topBar)

    InitialScreen.group = initialScreenGroup

    AnalyticsManager.enteredHomeScreen()

    return initialScreenGroup
end

function InitialScreen:hide(onComplete)
    if updateTimer then
        timer.cancel(updateTimer)
        updateTimer = nil
    end
    playBtn:hide(function()
        logo:hide()
        matchesFoil:hide(function()
            topBar:hide()
            bottomRanking:hide(function()
                InitialScreen:destroy()
                onComplete()
            end)
        end)
    end)
    rankingBtn:hide()
end

function InitialScreen:destroy()
    Runtime:removeEventListener("enterFrame", adjustScale)
    bottomRanking:destroy()
    topBar:destroy()
    matchesFoil:removeSelf()
    logo:removeSelf()
    playBtn:removeSelf()
    rankingBtn:removeSelf()
    if matchesGroup and matchesGroup.removeSelf then
        matchesGroup:removeSelf()
    end
    if initialScreenGroup and initialScreenGroup.removeSelf then
        initialScreenGroup:removeSelf()
    end
    matchesGroup = nil
    initialScreenGroup = nil
    bottomRanking = nil
    topBar = nil
    matchesFoil = nil
    logo = nil
    playBtn = nil
    rankingBtn = nil
end

return InitialScreen