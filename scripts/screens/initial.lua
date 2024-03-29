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
local tablesBtn
local videosBtn
local adjustScale
local matchesGroup
local isOpeningMatch
local updateTimer
local updateMatchesFoil
local isUpdatingMatchesFoil

local hasPlayNow
local hasScheduledMatches
local sawWelcomeAlert

local function createLogo()
    logo = TextureManager.newImage("stru_logotipo", initialScreenGroup)
    logo.x = logo.width*0.5
    logo.y = SCREEN_TOP + 108 + (display.screenOriginY*-.5)
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

    local buttonBg = TextureManager.newImageRect("images/stretchable/stru_bar_gold_mid.png", CONTENT_WIDTH, 47, buttonGroup)
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

local function setPlayButtonText(text)
    text.text = "TOQUE PARA JOGAR"
    text.size = 20
    --local TRANSITION_TIME = 2000
    --local ITERATION_TIME = 60
    --local currentTime = 0
    --local colorTo = 160
    --local colorFrom = 255
    --local down = true
    --local function bling()
    --    if not text.setTextColor then
    --        return
    --    end
    --    local newColor
    --    if down then
    --        newColor = easeInExpo(currentTime, TRANSITION_TIME, colorFrom, colorTo - colorFrom)
    --        if newColor <= colorTo + 1 then
    --            down = false
    --            currentTime = 0
    --            colorTo = 255
    --            colorFrom = newColor
    --        end
    --    else
    --        newColor = easeOutExpo(currentTime, TRANSITION_TIME, colorFrom, colorTo - colorFrom)
    --        if newColor >= colorTo - 1 then
    --            down = true
    --            currentTime = 0
    --            colorTo = 160
    --            colorFrom = newColor
    --        end
    --    end
    --    text:setTextColor(newColor)
    --    --print(newColor, currentTime)
    --    currentTime = currentTime + ITERATION_TIME
    --    timer.performWithDelay(ITERATION_TIME, bling)
    --end
    --bling()
    return text
end

local function createMatchView(match, y, currentDate)
    local matchGroup = display.newGroup()

    local function setPlayNow()
        local touchHandler = createTouchHandler(y)
        matchesGroup:insert(touchHandler)
        matchGroup.touchHandler = touchHandler

        if match.home_team.id == UserData.attributes.favorite_team_id or
                match.guest_team.id == UserData.attributes.favorite_team_id then
            Server:claimFavoriteTeamCoins(match.id)
        end
        hasPlayNow = true
    end

    local time = display.newText(string.utf8upper(match.starts_at:fmt("%a %d %b %Y - %H:%M")), 0, 0, "MyriadPro-BoldCond", 16)
    if match.status == "finished" then
        time.text = "ENCERRADO"
    elseif match.status == "scheduled" then
        local c = date.diff(currentDate, match.starts_at)
        local minutesToMatch = c:spanminutes()
        local daysDiff = currentDate:getyearday() - match.starts_at:getyearday()
        if minutesToMatch >= -5 then
            time = setPlayButtonText(time)
            setPlayNow()
        elseif daysDiff == -1 then
            time.text = "AMANHÃ - " .. string.utf8upper(match.starts_at:fmt("%H:%M"))
        elseif daysDiff == 0 then
            time.text = "HOJE - " .. string.utf8upper(match.starts_at:fmt("%H:%M"))
        end
    else
        time = setPlayButtonText(time)
        setPlayNow()
    end

    if DEBUG_MODE then setPlayNow() end

    time:setReferencePoint(display.TopCenterReferencePoint)
    time.x = -66
    time.y = 0

    local vs = display.newText("VS", 0, 0, "MyriadPro-BoldCond", 16)
    vs:setReferencePoint(display.TopRightReferencePoint)
    vs.x = -59
    vs.y = 48
    matchGroup:insert(time)
    matchGroup:insert(vs)

    local homeTeamBadge = TextureManager.newLogo(getLogoFileName(match.home_team.id, 2), 64, matchGroup)
    homeTeamBadge.x = -110
    homeTeamBadge.y = 50
    local awayTeamBadge = TextureManager.newLogo(getLogoFileName(match.guest_team.id, 2), 64, matchGroup)
    awayTeamBadge.x = -25
    awayTeamBadge.y = 50

    matchGroup:setReferencePoint(display.TopRightReferencePoint)
    matchGroup.x = (160 + (-display.screenOriginX))*0.5 - 4 + display.screenOriginX*0.5
    matchGroup.y = y + 4
    matchGroup.baseY = y + 4
    hasScheduledMatches = true
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

    local matches = MatchManager:getNextEightMatches()
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
            hideScrollBar = true,
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
                AnalyticsManager.setFromScreen("HomeScreen")
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
        if match.status ~= "finished" then
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

local function showWelcomeAlert()
    if not sawWelcomeAlert then
        if not hasScheduledMatches then
            native.showAlert("Bem-vindo ao Chute Premiado!",
                "Não encontramos nenhum jogo agendado. Por favor, retorne mais tarde.",
                {"Ok"})
        elseif not hasPlayNow then
            native.showAlert("Bem-vindo ao Chute Premiado!",
                "Neste momento, não há nenhum jogo em andamento. Por favor, retorne no horário do jogo.",
                {"Ok"})
        end
        sawWelcomeAlert = true
    end
end

local function createMatchesFoil(onComplete)
    matchesFoil = display.newGroup()
    local matchesFoilCenter = TextureManager.newImageRect("images/matches_foil/stru_mainfoil_center.png", 72 + (-display.screenOriginX), 421, matchesFoil) --88 420
    matchesFoilCenter.x = SCREEN_RIGHT - matchesFoilCenter.width*0.5
    matchesFoilCenter.y = display.contentCenterY
    local matchesFoilBorder = TextureManager.newImageRect("images/matches_foil/stru_mainfoil_border.png", 88, 421, matchesFoil) --88 420
    matchesFoilBorder.x = matchesFoilCenter.x - matchesFoilCenter.width*0.5 - matchesFoilBorder.width*0.5
    matchesFoilBorder.y = display.contentCenterY

    if MatchManager.initialized then
        matchesFoil:insert(createMatchesView(SCREEN_RIGHT - (160 + (-display.screenOriginX))*0.5, display.contentCenterY - 210))
        --showWelcomeAlert()
    else
        isUpdatingMatchesFoil = false
        MatchManager:addListener(updateMatchesFoil)
        local widget = require( "widget" )
        local spinnerDefault = widget.newSpinner()
        spinnerDefault.x = SCREEN_RIGHT - matchesFoilCenter.width*0.75
        spinnerDefault.y = display.contentCenterY
        spinnerDefault:start()
        matchesFoil:insert(spinnerDefault)
        matchesFoil.spinnerDefault = spinnerDefault
    end
    matchesFoil.isVisible = false
    function matchesFoil:showUp(onComplete)
        self.isVisible = true
        transition.from(self, {time = 1000, x = SCREEN_RIGHT + self.width, transition = easeOutQuad, onComplete = function()
            pcall(function()
                if matchesGroup and matchesGroup.insert and not matchesGroup.scrolling then
                    matchesGroup.scrolling = true
                    timer.performWithDelay(1000, function() matchesGroup.scrolling = false end)
                    matchesGroup:scrollTo("bottom", {time = 1000})
                end
                onComplete()
            end)
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
        tablesBtn:showUp()
        videosBtn:showUp()
    end)
    return matchesFoil
end

function InitialScreen:showUp(onComplete)
    isUpdatingMatchesFoil = true
    bottomRanking:showUp(function()
        topBar:showUp()
        logo:showUp()
        initialScreenGroup:insert(6, createMatchesFoil(function()
            isUpdatingMatchesFoil = false
            if onComplete then
                onComplete()
            end
            if UserData.showFacebookLogin then
                UserData.showFacebookLogin = false
                require("scripts.widgets.view.initial_pop_up"):new("images/pop_up.png",
                function()
                    UserData:reset()
                    return true
                end)
            elseif UserData.showSubscriptionOffer and not UserData.inventory.subscribed then
                UserData.showSubscriptionOffer = false
                local imageFileName
                if IS_ANDROID then
                    imageFileName = "images/pop_up_subs_android.png"
                else
                    imageFileName = "images/pop_up_subs_ios.png"
                end
                require("scripts.widgets.view.initial_pop_up"):new(imageFileName,
                function()
                    StoreManager.buyThis("semana")
                    return true
                end)
            end
            PushNotification:parseUnsubscribe()
        end))
    end)
end

function updateMatchesFoil()
    if isUpdatingMatchesFoil or not initialScreenGroup then
        return
    end
    lockScreen()
    isUpdatingMatchesFoil = true
    if updateTimer then
        timer.cancel(updateTimer)
        updateTimer = nil
    end
    Runtime:removeEventListener("enterFrame", adjustScale)
    display.getCurrentStage():setFocus(nil)
    if matchesFoil.spinnerDefault and matchesFoil.spinnerDefault.removeSelf then
        matchesFoil.spinnerDefault:stop()
        matchesFoil.spinnerDefault:removeSelf()
        matchesFoil.spinnerDefault = nil
    end

    local function newMatchesGroup()
        matchesFoil:insert(createMatchesView(SCREEN_RIGHT - (160 + (-display.screenOriginX))*0.5, display.contentCenterY - 210))
        --showWelcomeAlert()
        matchesGroup.scrolling = true
        transition.from(matchesGroup, {delay = 500, time = 500, alpha = 0, onComplete = function()
            if matchesGroup then
                timer.performWithDelay(1000, function()
                    if matchesGroup then
                        matchesGroup.scrolling = false
                    end
                    unlockScreen()
                end)
                matchesGroup:scrollTo("bottom", {time = 1000})
                isUpdatingMatchesFoil = false
            end
        end})
    end

    if matchesGroup then
        transition.to(matchesGroup, {time = 500, alpha = 0, onComplete = function()
            matchesGroup:removeSelf()
            newMatchesGroup()
        end})
    else
        newMatchesGroup()
    end

    --if playBtn then
    --    playBtn:hide(function()
    --        matchesFoil:hide(function()
    --            matchesFoil:removeSelf()
    --            initialScreenGroup:insert(6, createMatchesFoil(function() isUpdatingMatchesFoil = false end))
    --            --showWelcomeAlert()
    --        end)
    --    end)
    --end
    --if rankingBtn then rankingBtn:hide() end
    --if tablesBtn then tablesBtn:hide() end
    --if videosBtn then videosBtn:hide() end
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

    videosBtn = BtnHomeScreen:new(display.contentCenterY - 30, "GOLS DA RODADA", true, function()
        ScreenManager:show("videos")
        AudioManager.playAudio("hideInitialScreen")
    end)
    initialScreenGroup:insert(videosBtn)

    tablesBtn = BtnHomeScreen:new(display.contentCenterY + 17, "CLASSIFICAÇÃO", false, function()
        ScreenManager:show("tables")
        AudioManager.playAudio("hideInitialScreen")
    end)
    initialScreenGroup:insert(tablesBtn)

    playBtn = BtnHomeScreen:new(display.contentCenterY + 64, "PARTIDAS", false, function()
        MatchManager:resquestMatches()
        ScreenManager:show("select_match")
        AudioManager.playAudio("hideInitialScreen")
    end)
    initialScreenGroup:insert(playBtn)

    rankingBtn = BtnHomeScreen:new(display.contentCenterY + 111, "RANKING", false, function()
        if UserData.demoModeOn then
            local function onComplete(event)
                if "clicked" == event.action then
                    local i = event.index
                    if 1 == i then
                        ScreenManager:show("ranking")
                        AudioManager.playAudio("hideInitialScreen")
                    elseif 2 == i then
                        UserData:reset()
                    end
                end
            end
            native.showAlert("Ganhe prêmios!", "Cadastre-se no Facebook e dispute pelo prêmio semanal junto com seus amigos.", {"Mais tarde.", "Cadastrar."}, onComplete)
        else
            ScreenManager:show("ranking")
            AudioManager.playAudio("hideInitialScreen")
        end
    end)
    initialScreenGroup:insert(rankingBtn)

    bottomRanking = BottomRanking:new(true)
    initialScreenGroup:insert(bottomRanking)

    topBar = TopBar:new(true)
    topBar:updateTotalCoins(UserData.inventory.coins)
    initialScreenGroup:insert(topBar)

    InitialScreen.group = initialScreenGroup

    AnalyticsManager.enteredHomeScreen()

    if not MatchManager.initialized then
        tablesBtn:lock(true)
        playBtn:lock(true)
        MatchManager:addListener(function()
            tablesBtn:lock(false)
            playBtn:lock(false)
        end)
    end

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
    tablesBtn:hide()
    videosBtn:hide()
end

function InitialScreen:destroy()
    Runtime:removeEventListener("enterFrame", adjustScale)
    bottomRanking:destroy()
    topBar:destroy()
    matchesFoil:removeSelf()
    logo:removeSelf()
    playBtn:removeSelf()
    rankingBtn:removeSelf()
    tablesBtn:removeSelf()
    videosBtn:removeSelf()
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
    tablesBtn = nil
    videosBtn = nil
end

return InitialScreen