--[[==============
== We Love Quiz
== Date: 14/06/13
== Time: 12:15
==============]]--
local widget = require "widget"
require "scripts.widgets.view.top_bar_menu"
require "scripts.widgets.view.button_open_menu"

SelectMatchScreen = {}

local selectMatchGroup
local isBgOpen
local isOpeningMatch
local isInTransition
local championshipButtons
local updateTimer

local function closeChampionshipButtons(openingButton)
    for i, button in ipairs(championshipButtons) do
        if button ~= openingButton and button.isOpen then
            button:close()
            button.isOpen = false
            button.parent[button.parent.numChildren].isVisible = true
        end
    end
end

local function displaceOpenChampBtns(openingButtonY, partHeight)
    for i, button in ipairs(championshipButtons) do
        if button.y > openingButtonY then
            transition.to(button.parent, {time = 200, y = button.parent.y + partHeight})
        end
    end
end

local function displaceCloseChampBtns()
    for i, button in ipairs(championshipButtons) do
        transition.to(button.parent, {time = 200, y = SCREEN_TOP + 68})
    end
end

local function createTouchHandler(yPos)
    local touchHandler = display.newRect(display.screenOriginX + 1, yPos - 3, CONTENT_WIDTH - 2, 74)
    touchHandler.strokeWidth = 2
    touchHandler:setStrokeColor(0, 0, 0, 64)
    local g = graphics.newGradient(
        { 180,  180,  180, 128 },
        { 0,  0,  0, 96 },
        "down" )
    touchHandler:setFillColor( g )
    touchHandler.alpha = 0.01
    return touchHandler
end

local function createMatchView(match, matchesGroup, yPos)
    local matchGroup = display.newGroup()

    local teamsNames = display.newText(matchGroup, string.utf8upper(match.home_team.name .. "   VS   " .. match.guest_team.name), 0, 0, "MyriadPro-BoldCond", 14)
    if teamsNames.width > 175 then
        local scale = 175/teamsNames.width
        teamsNames.xScale = scale
        teamsNames.yScale = scale
    end
    teamsNames.x = display.contentCenterX
    teamsNames.y = 0
    teamsNames:setTextColor(135)

    local function setPlayNow()
        local touchHandler = createTouchHandler(yPos)
        matchesGroup:insert(touchHandler)
        matchGroup.touchHandler = touchHandler

        if match.home_team.id == UserData.attributes.favorite_team_id or
                match.guest_team.id == UserData.attributes.favorite_team_id then
            Server:claimFavoriteTeamCoins(match.id)
        end
    end

    local time = display.newText(matchGroup, match.starts_at:fmt("%H:%M"), 0, 0, "MyriadPro-BoldCond", 24)
    local status = display.newText(matchGroup, "AGUARDANDO", 0, 0, "MyriadPro-BoldCond", 14)
    status:setTextColor(135)

    if match.status == "finished" then
        time.text = match.home_goals .. " - " .. match.guest_goals
        status.text = "ENCERRADO"
    elseif match.status == "scheduled" then
        local c = date.diff(getCurrentDate(), match.starts_at)
        local minutesToMatch = c:spanminutes()
        if minutesToMatch >= -5 then
            time.text = match.home_goals .. " - " .. match.guest_goals
            status.text = "JOGUE AGORA"
            status.size = 16
            status:setTextColor(0)
            setPlayNow()
        end
    else
        time.text = match.home_goals .. " - " .. match.guest_goals
        status.text = "JOGUE AGORA"
        status.size = 16
        status:setTextColor(0)
        setPlayNow()
    end

    if DEBUG_MODE then setPlayNow() end

    time:setReferencePoint(display.CenterReferencePoint)
    time.x = display.contentCenterX
    time.y = 24
    time:setTextColor(0)
    status.x = display.contentCenterX
    status.y = 52

    matchGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, 62, CONTENT_WIDTH*0.9))
    local homeTeamBadge = TextureManager.newLogo(getLogoFileName(match.home_team.id, 2), 64, matchGroup)
    homeTeamBadge.x = 40
    homeTeamBadge.y = 24
    local awayTeamBadge = TextureManager.newLogo(getLogoFileName(match.guest_team.id, 2), 64, matchGroup)
    awayTeamBadge.x = display.contentWidth - 40
    awayTeamBadge.y = 24

    return matchGroup
end

local openBG
local closeBG

local function updateMatchesFoil()
    if updateTimer then
        timer.cancel(updateTimer)
        updateTimer = nil
    end
    if selectMatchGroup.openButton then
        display.getCurrentStage():setFocus(nil)
        openBG(selectMatchGroup.openButton, selectMatchGroup.openChampNum)
    end
end

local function createChampionshipMatchesView(matchesList, topY)
    -- Create a ScrollView
    local scrollSize = #matchesList < 3 and #matchesList*73 or 258
    local distToBottom = SCREEN_BOTTOM - topY
    scrollSize = distToBottom < scrollSize and distToBottom or scrollSize
    local matchesGroup = widget.newScrollView
        {
            width = SCREEN_RIGHT,
            height = scrollSize,
            maskFile = "images/masks/menumatches_mask.png",
            hideBackground = true,
            hideScrollBar = true,
            horizontalScrollDisabled = true,
            verticalScrollDisabled = #matchesList < 3
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
                AnalyticsManager.setFromScreen("ChooseMatchScreen")
                MatchManager:setCurrentMatch(button.matchId)
                isOpeningMatch = true
                button:removeEventListener("touch", button)
            end
        end
        return true
    end

    matchesGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, 6, CONTENT_WIDTH*0.9))

    local function createDateSeparator(_date, y)
        local dateTxt = display.newText(string.utf8upper(_date:fmt("%a %d %b %Y")), 4, y, "MyriadPro-BoldCond", 12)
        dateTxt:setTextColor(0)
        matchesGroup:insert(dateTxt)
        matchesGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, y + 16, CONTENT_WIDTH*0.9))
    end

    local currentStartsAt
    local yPos = 9
    local nextUpdateTime
    local currentDate = getCurrentDate()
    for i, match in ipairs(matchesList) do
        if not currentStartsAt or currentStartsAt:getyearday() < match.starts_at:getyearday() then
            currentStartsAt = match.starts_at
            --print("createDateSeparator", dateSeparatorCount*((i - 1)*64))
            createDateSeparator(match.starts_at, yPos)
            yPos = yPos + 20
        end
        --print("createMatchView", (i - 1)*73 + (dateSeparatorCount*42))
        local matchView = createMatchView(match, matchesGroup, yPos)
        matchView:setReferencePoint(display.TopCenterReferencePoint)
        matchView.x = display.contentCenterX
        matchView.y = yPos
        if matchView.touchHandler then
            matchView.touchHandler.matchId = match.id
            matchView.touchHandler.touch = onEnterMatch
            matchView.touchHandler.group = matchView
            matchView.touchHandler:addEventListener("touch", matchView.touchHandler)
        end
        matchesGroup:insert(matchView)
        yPos = yPos + 73

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

    matchesGroup.y = topY - 8

    --print(scrollSize, matchesGroup.height)
    return matchesGroup
end

function closeBG(onClose)
    selectMatchGroup.openButton = nil
    selectMatchGroup.openChampNum = nil
    selectMatchGroup.bg:close(function()
        selectMatchGroup[1]:removeSelf()
        isBgOpen = false
        if onClose then
            timer.performWithDelay(200, onClose)
        else
            isInTransition = false
            unlockScreen()
        end
    end)
    displaceCloseChampBtns()
    isInTransition = true
    lockScreen()
end

function openBG(button, champNum)
    local yOpenPart = button.y + SCREEN_TOP + 89
    local partHeight
    if isBgOpen then
        closeBG(function()
            closeChampionshipButtons(button)
            openBG(button, champNum)
        end)
        return
    end
    isBgOpen = true
    selectMatchGroup.openButton = button
    selectMatchGroup.openChampNum = champNum
    selectMatchGroup:insert(1, createChampionshipMatchesView(MatchManager:getChampionshipsList()[champNum].incoming_matches, yOpenPart + 8))
    local distToBottom = SCREEN_BOTTOM - yOpenPart
    partHeight = distToBottom < 262 and distToBottom or (selectMatchGroup[1].height < 262 and selectMatchGroup[1].height + 4 or 262)
    selectMatchGroup.bg:open(yOpenPart, partHeight, function()
        isInTransition = false
        unlockScreen()
    end)

    button:open()
    button.parent[button.parent.numChildren].isVisible = false
    displaceOpenChampBtns(button.y, partHeight)

    isInTransition = true
    lockScreen()
end

local function createOpenMenuLine(isBottom)
    local lineGroup = display.newGroup()
    local line = display.newLine(lineGroup, SCREEN_LEFT, display.screenOriginY, SCREEN_RIGHT, display.screenOriginY)
    if isBottom then
        line:setColor(255)
    else
        line:setColor(135, 224)
    end
    local lineShadow = TextureManager.newImageRect("images/stretchable/stru_shadow.png", CONTENT_WIDTH, 20, lineGroup)
    lineShadow.x = display.contentCenterX
    lineShadow.y = display.screenOriginY + (isBottom and -10 or 10)
    lineShadow.yScale = isBottom and -lineShadow.yScale or lineShadow.yScale
    lineGroup:setReferencePoint(isBottom and display.BottomCenterReferencePoint or display.TopCenterReferencePoint)

    return lineGroup
end

local function createBG()
    local bgGroup = display.newGroup()

    local bgTop = TextureManager.newImageRect("images/stretchable/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, bgGroup)
    bgTop.x = display.contentCenterX
    bgTop.y = display.contentCenterY
    local menuMask = graphics.newMask("images/masks/menuselectmatch_mask.png")
    bgTop:setMask(menuMask)
    local bgBottom = TextureManager.newImageRect("images/stretchable/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, bgGroup)
    bgBottom.x = display.contentCenterX
    bgBottom.y = display.contentCenterY
    local menuMask = graphics.newMask("images/masks/menuselectmatch_mask.png")
    bgBottom:setMask(menuMask)

    local CENTER_MASK_Y = 282.5
    bgTop.maskY = -CENTER_MASK_Y
    bgBottom.maskY = CENTER_MASK_Y

    local lineTop = createOpenMenuLine(false)
    bgGroup:insert(lineTop)

    local lineBottom = createOpenMenuLine(true)
    bgGroup:insert(lineBottom)

    function bgGroup:showUp(onComplete)
        self.isVisible = true
        transition.from(self, {time = 500, alpha = 0, onComplete = onComplete})
    end

    function bgGroup:hide()
        transition.to(self, {time = 500, alpha = 0, onComplete = SelectMatchScreen.destroy})
    end

    function bgGroup:open(yOpenPart, partHeight, onComplete)
        lineTop.y = yOpenPart - 1
        lineBottom.y = lineTop.y + 1
        lineBottom.alpha = 0
        transition.to(lineBottom, {time = 200, y = yOpenPart + partHeight + 2, alpha = 1})

        bgTop.maskY = -CENTER_MASK_Y - (display.contentCenterY) + yOpenPart
        bgBottom.maskY = CENTER_MASK_Y - (display.contentCenterY) + yOpenPart
        transition.to(bgBottom, {time = 200, maskY = CENTER_MASK_Y - (display.contentCenterY) + yOpenPart + partHeight, onComplete = onComplete})
    end

    function bgGroup:close(onComplete)
        transition.to(bgBottom, {time = 200, maskY = CENTER_MASK_Y*2 + bgTop.maskY, onComplete = onComplete})
        lineTop.y = display.screenOriginY
        lineBottom.y = display.screenOriginY
    end

    return bgGroup
end

local function createChampionshipsList(championshipList)
    local championshipsListGroup = display.newGroup()
    local Y_CHAMPIONSHIP = 50
    for i, championship in ipairs(championshipList) do
        local championshipGroup = display.newGroup()
        local title = display.newText(string.utf8upper(championship.name), 0, 0, "MyriadPro-BoldCond", 24)
        title.x = title.width*0.5 + 8
        title.y = (i - 1)*Y_CHAMPIONSHIP
        title:setTextColor(0)
        local arrow = ButtonOpenMenu:new(function(button, event)
            if isInTransition then
                return true
            end
            button.isOpen = not button.isOpen
            if button.isOpen then
                openBG(button, i)
            else
                closeBG()
                button:close()
                button.parent[button.parent.numChildren].isVisible = true
            end
            return true
        end)
        championshipGroup:insert(arrow)
        arrow.x = SCREEN_RIGHT - arrow.width*0.5
        arrow.y = (i - 1)*Y_CHAMPIONSHIP - 6
        arrow:lock(true)
        championshipGroup:insert(title)
        championshipButtons[#championshipButtons + 1] = arrow
        championshipGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, (i - 1)*Y_CHAMPIONSHIP + title.height*0.5 + 4, CONTENT_WIDTH*0.9))
        championshipGroup.x = 0
        championshipGroup.y = SCREEN_TOP + 68

        local spinnerDefault = LoadingBall:createBall(SCREEN_RIGHT - 20, (i - 1)*Y_CHAMPIONSHIP)
        championshipGroup:insert(spinnerDefault)
        Server:downloadTeamsLogos({sizes = "medium", matches = championship.incoming_matches, listener = function()
            spinnerDefault:removeSelf()
            arrow:lock(false)
        end})

        championshipsListGroup:insert(championshipGroup)
    end

    championshipsListGroup.isVisible = false
    function championshipsListGroup:showUp()
        self.isVisible = true
        for i = 1, self.numChildren do
            transition.from(self[i], {delay = 300, time = 300, y = 50*-i - 50, transition = easeInQuart})
            if i == 1 then
                timer.performWithDelay(900, function()
                    self[i][1].isOpen = true
                    openBG(self[i][1], i)
                end)
            end
        end
        if self.numChildren > 0 then
            AudioManager.playAudio("openCloseMenu", 500)
        end
    end

    function championshipsListGroup:hide()
        for i = 1, self.numChildren do
            transition.to(self[i], {time = 300, y = 50*-i - 50, transition = easeInQuart})
        end
    end

    return championshipsListGroup
end

function SelectMatchScreen.onAppResume()
    updateMatchesFoil()
end

function SelectMatchScreen:showUp(onComplete)
    selectMatchGroup.bg:showUp(function()
        selectMatchGroup.championshipsList:showUp()
        selectMatchGroup.topBar.isVisible = true
        transition.from(selectMatchGroup.topBar, {time = 300, y = SCREEN_TOP - 50, transition = easeInQuart})
        AudioManager.playAudio("showTopBar")
        timer.performWithDelay(650, function()
            onComplete()
            lockScreen()
        end)
    end)
end

function SelectMatchScreen:hide(onComplete)
    if updateTimer then
        timer.cancel(updateTimer)
        updateTimer = nil
    end
    local function hiding()
        selectMatchGroup.championshipsList:hide()
        transition.to(selectMatchGroup.topBar, {delay = 300, time = 300, y = SCREEN_TOP - 50, transition = easeInQuart, onComplete = function()
            selectMatchGroup.bg:hide()
            onComplete()
        end})
    end

    if isBgOpen then
        closeBG(hiding)
    else
        hiding()
    end
end

function SelectMatchScreen:new()
    isBgOpen = false
    isOpeningMatch = false
    isInTransition = false
    selectMatchGroup = display.newGroup()
    championshipButtons = {}

    selectMatchGroup.bg = createBG()
    selectMatchGroup:insert(selectMatchGroup.bg)
    selectMatchGroup.championshipsList = createChampionshipsList(MatchManager:getChampionshipsList())
    selectMatchGroup:insert(selectMatchGroup.championshipsList)
    selectMatchGroup.topBar = TopBarMenu:new("JOGAR")
    selectMatchGroup.topBar.isVisible = false
    selectMatchGroup:insert(selectMatchGroup.topBar)

    AnalyticsManager.enteredSelectMatchScreen()

    return selectMatchGroup
end

function SelectMatchScreen:destroy()
    selectMatchGroup:removeSelf()
    selectMatchGroup = nil
    championshipButtons = nil
end

return SelectMatchScreen