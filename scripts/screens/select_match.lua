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
local bgGroup
local championshipsListGroup
local championshipButtons
local isOpeningMatch

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

local function createTouchHandler(matchGroup, yPos)
    local touchHandler = display.newRect(display.screenOriginX + 1, yPos - 3, CONTENT_WIDTH - 2, 74)
    touchHandler.strokeWidth = 2
    touchHandler:setStrokeColor(0, 0, 0, 64)
    local g = graphics.newGradient(
        { 180,  180,  180, 128 },
        { 0,  0,  0, 96 },
        "down" )
    touchHandler:setFillColor( g )
    touchHandler.alpha = 0.01
    matchGroup:insert(touchHandler)
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

    local time
    local status
    local currentDate = getCurrentDate()
    local daysDiff = currentDate:getyearday() - match.starts_at:getyearday()
    if daysDiff > 0 then
        time = display.newText(matchGroup, match.home_goals .. " - " .. match.guest_goals, 0, 0, "MyriadPro-BoldCond", 24)
        status = display.newText(matchGroup, "ENCERRADO", 0, 0, "MyriadPro-BoldCond", 14)
        status:setTextColor(135)
    elseif daysDiff < 0 then
        time = display.newText(matchGroup, match.starts_at:fmt("%H:%M"), 0, 0, "MyriadPro-BoldCond", 24)
        status = display.newText(matchGroup, "AGUARDANDO", 0, 0, "MyriadPro-BoldCond", 14)
        status:setTextColor(135)
    elseif daysDiff == 0 then
        local c = date.diff(currentDate, match.starts_at)
        local minutesToMatch = c:spanminutes()
        if minutesToMatch > 110 then
            time = display.newText(matchGroup, match.home_goals .. " - " .. match.guest_goals, 0, 0, "MyriadPro-BoldCond", 24)
            status = display.newText(matchGroup, "ENCERRADO", 0, 0, "MyriadPro-BoldCond", 14)
            status:setTextColor(135)
        elseif minutesToMatch >= -5 then
            time = display.newText(matchGroup, match.home_goals .. " - " .. match.guest_goals, 0, 0, "MyriadPro-BoldCond", 24)
            status = display.newText(matchGroup, "JOGUE AGORA", 0, 0, "MyriadPro-BoldCond", 16)
            status:setTextColor(0)
            matchGroup.touchHandler = createTouchHandler(matchesGroup, yPos)
        else
            time = display.newText(matchGroup, match.starts_at:fmt("%H:%M"), 0, 0, "MyriadPro-BoldCond", 24)
            status = display.newText(matchGroup, "AGUARDANDO", 0, 0, "MyriadPro-BoldCond", 14)
            status:setTextColor(135)
        end
    end

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

local function createChampionshipMatchesView(matchesList, topY)
    local widget = require "widget"
    -- Create a ScrollView
    local scrollSize = #matchesList < 3 and #matchesList*73 or 258
    local distToBottom = SCREEN_BOTTOM - topY
    scrollSize = distToBottom < scrollSize and distToBottom or scrollSize
    local matchesGroup = widget.newScrollView
        {
            width = SCREEN_RIGHT,
            height = scrollSize,
            maskFile = "images/menumatches_mask.png",
            hideBackground = true,
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
        elseif event.phase == "moved" then
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
        elseif button.isFocus and event.phase == "ended" then
            button.alpha = 0.01
            button.group.x = button.group.x - 1
            button.group.y = button.group.y - 1
            display.getCurrentStage():setFocus(nil)
            MatchManager:setCurrentMatch(button.matchId)
            isOpeningMatch = true
            button:removeEventListener("touch", button)
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

    local currentDate
    local yPos = 9

    for i, match in ipairs(matchesList) do
        if not currentDate or currentDate:getyearday() < match.starts_at:getyearday() then
            currentDate = match.starts_at
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
    end

    matchesGroup.y = topY - 8

    --print(scrollSize, matchesGroup.height)
    return matchesGroup
end

local function createOpenMenuLine(isBottom)
    local lineGroup = display.newGroup()
    local line = display.newLine(lineGroup, SCREEN_LEFT, display.screenOriginY, SCREEN_RIGHT, display.screenOriginY)
    if isBottom then
        line:setColor(255)
    else
        line:setColor(135, 224)
    end
    local lineShadow = TextureManager.newImageRect("images/stru_shadow.png", CONTENT_WIDTH, 20, lineGroup)
    lineShadow.x = display.contentCenterX
    lineShadow.y = display.screenOriginY + (isBottom and -10 or 10)
    lineShadow.yScale = isBottom and -lineShadow.yScale or lineShadow.yScale
    lineGroup:setReferencePoint(isBottom and display.BottomCenterReferencePoint or display.TopCenterReferencePoint)

    return lineGroup
end

local function createBG()
    bgGroup = display.newGroup()

    local bgTop = TextureManager.newImageRect("images/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, bgGroup)
    bgTop.x = display.contentCenterX
    bgTop.y = display.contentCenterY
    local menuMask = graphics.newMask("images/menuselectmatch_mask.png")
    bgTop:setMask(menuMask)
    local bgBottom = TextureManager.newImageRect("images/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, bgGroup)
    bgBottom.x = display.contentCenterX
    bgBottom.y = display.contentCenterY
    local menuMask = graphics.newMask("images/menuselectmatch_mask.png")
    bgBottom:setMask(menuMask)

    local CENTER_MASK_Y = 282.5
    bgTop.maskY = -CENTER_MASK_Y
    bgBottom.maskY = CENTER_MASK_Y

    local lineTop = createOpenMenuLine(false)
    bgGroup:insert(lineTop)

    local lineBottom = createOpenMenuLine(true)
    bgGroup:insert(lineBottom)

    function SelectMatchScreen:openBG(button, champNum)
        local yOpenPart = button.y + SCREEN_TOP + 89
        local partHeight
        if self.isOpen then
            SelectMatchScreen:closeBG(function()
                closeChampionshipButtons(button)
                SelectMatchScreen:openBG(button, champNum)
            end)
            return
        end
        selectMatchGroup:insert(1, createChampionshipMatchesView(MatchManager:getChampionshipsList()[champNum].incoming_matches, yOpenPart + 8))
        local distToBottom = SCREEN_BOTTOM - yOpenPart
        partHeight = distToBottom < 262 and distToBottom or (selectMatchGroup[1].height < 262 and selectMatchGroup[1].height + 4 or 262)
        lineTop.y = yOpenPart - 1
        lineBottom.y = lineTop.y + 1
        lineBottom.alpha = 0
        transition.to(lineBottom, {time = 200, y = yOpenPart + partHeight + 2, alpha = 1})

        bgTop.maskY = -CENTER_MASK_Y - (display.contentCenterY) + yOpenPart
        bgBottom.maskY = CENTER_MASK_Y - (display.contentCenterY) + yOpenPart
        transition.to(bgBottom, {time = 200, maskY = CENTER_MASK_Y - (display.contentCenterY) + yOpenPart + partHeight, onComplete = function()
            self.isOpen = true
            self.inTransition = false
            unlockScreen()
        end})

        button:open()
        button.parent[button.parent.numChildren].isVisible = false
        displaceOpenChampBtns(button.y, partHeight)

        self.inTransition = true
        lockScreen()
    end

    function SelectMatchScreen:closeBG(onClose)
        transition.to(bgBottom, {time = 200, maskY = CENTER_MASK_Y*2 + bgTop.maskY, onComplete = function()
            selectMatchGroup[1]:removeSelf()
            self.isOpen = false
            if onClose then
                timer.performWithDelay(200, onClose)
            else
                self.inTransition = false
                unlockScreen()
            end
        end})
        lineTop.y = display.screenOriginY
        lineBottom.y = display.screenOriginY
        displaceCloseChampBtns()
        self.inTransition = true
        lockScreen()
    end

    return bgGroup
end

local function createChampionshipsList(championshipList)
    championshipsListGroup = display.newGroup()
    local Y_CHAMPIONSHIP = 50
    for i, championship in ipairs(championshipList) do
        local championshipGroup = display.newGroup()
        local title = display.newText(string.utf8upper(championship.name), 0, 0, "MyriadPro-BoldCond", 24)
        title.x = title.width*0.5 + 8
        title.y = (i - 1)*Y_CHAMPIONSHIP
        title:setTextColor(0)
        local arrow = ButtonOpenMenu:new(function(button, event)
            if SelectMatchScreen.inTransition then
                return true
            end
            button.isOpen = not button.isOpen
            if button.isOpen then
                SelectMatchScreen:openBG(button, i)
            else
                SelectMatchScreen:closeBG()
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
        MatchManager:downloadTeamsLogos({sizes = "medium", matches = championship.incoming_matches, listener = function()
            spinnerDefault:removeSelf()
            arrow:lock(false)
        end})

        championshipsListGroup:insert(championshipGroup)
    end
    return championshipsListGroup
end

function SelectMatchScreen:showUp(onComplete)
    bgGroup.isVisible = true
    transition.from(bgGroup, {time = 500, alpha = 0, onComplete = function()
        championshipsListGroup.isVisible = true
        selectMatchGroup[selectMatchGroup.numChildren].isVisible = true
        for i = 1, championshipsListGroup.numChildren do
            transition.from(championshipsListGroup[i], {delay = 300, time = 300, y = 50*-i - 50, transition = easeInQuart})
        end
        transition.from(selectMatchGroup[selectMatchGroup.numChildren], {time = 300, y = SCREEN_TOP - 50, transition = easeInQuart})
        timer.performWithDelay(650, onComplete)
    end})
end

function SelectMatchScreen:new()
    isOpeningMatch = false
    SelectMatchScreen.inTransition = false
    selectMatchGroup = display.newGroup()
    championshipButtons = {}

    selectMatchGroup:insert(createBG())
    selectMatchGroup:insert(createChampionshipsList(MatchManager:getChampionshipsList()))
    selectMatchGroup:insert(TopBarMenu:new("JOGAR"))

    bgGroup.isVisible = false
    championshipsListGroup.isVisible = false
    selectMatchGroup[selectMatchGroup.numChildren].isVisible = false

    return selectMatchGroup
end

function SelectMatchScreen:hide(onComplete)
    SelectMatchScreen:closeBG(function()
        for i = 1, championshipsListGroup.numChildren do
            transition.to(championshipsListGroup[i], {time = 300, y = 50*-i - 50, transition = easeInQuart})
        end
        transition.to(selectMatchGroup[selectMatchGroup.numChildren], {delay = 300, time = 300, y = SCREEN_TOP - 50, transition = easeInQuart, onComplete = function()
            onComplete()
            transition.to(bgGroup, {time = 500, alpha = 0, onComplete = SelectMatchScreen.destroy})
        end})
    end)
end

function SelectMatchScreen:destroy()
    bgGroup:removeSelf()
    championshipsListGroup:removeSelf()
    selectMatchGroup:removeSelf()
    selectMatchGroup = nil
    bgGroup = nil
    championshipsListGroup = nil
    championshipButtons = nil
end

return SelectMatchScreen